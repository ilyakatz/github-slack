require 'sinatra'
require 'pry'
require 'json'
require 'octokit'
require "slack"

ACCESS_TOKEN  = ENV['MY_PERSONAL_TOKEN']
SLACK_CHANNEL = ENV['SLACK_CHANNEL']

Slack.configure do |config|
  config.token = ENV['SLACK_TOKEN']
end

get '/' do
  "Hello from sinatra! The time is #{ Time.now.to_i } on #{ `hostname` }!"
end

post '/' do
  body = request.body.read
  @payload = JSON.parse(body)

  case request.env['HTTP_X_GITHUB_EVENT']
  when "pull_request"
    process_pull_request(@payload["pull_request"])
  end

  if @payload["context"] && @payload["context"] == "ci/circleci"
    process_circle_ci(@payload["pull_request"])
  end

  "OK"
end

helpers do

  def process_circle_ci(payload)
    if leankit_ticket_present?(pull_request["head"]["ref"])
      client.create_status(
        payload["name"],
        payload["sha"],
        build_status,
        opts.merge("description" => slack_channel_topic)
      )
    end
  end

  # @param pull_request Hash hash that is returned by Github API that identifies a PR
  def process_pull_request(pull_request)
    client.create_status(
      repo_name(pull_request),
      pull_request['head']['sha'],
      build_status(pull_request),
      opts.merge(description: description(pull_request))
    )
  end

  def client
    @client ||= Octokit::Client.new(:access_token => ACCESS_TOKEN)
  end

  def leankit_ticket_present?(pull_request)
    commit_messages(pull_request).any? do |comment|
      leankit_identifiable?(comment)
    end
  end

  def leankit_identifiable?(comment)
    !!(comment =~ /(\d{6,10})/)
  end

  def hotfix?(branch_name)
    !!(branch_name =~ /production-/)
  end

  def repo_name(pull_request)
    pull_request['base']['repo']['full_name']
  end

  def pull_request_number(pull_request)
    pull_request["number"]
  end

  def build_status(pull_request)
    leankit_ticket_present?(pull_request) ? "success" : "error"
  end

  def description(pull_request)
    d = leankit_ticket_present?(pull_request) ?
      slack_channel_topic :
      "None of the messages in the PR include LeanKit ID"

    puts d
    d
  end

  def opts
    {
      "target_url" => "https://execonline.slack.com",
      "context" => "exo/deploy"
    }
  end

  def channel
    SLACK_CHANNEL
  end

  def slack_channel_topic
    info = slack_client.channels_info(channel: channel)
    if c = info["channel"]
      c["topic"]["value"]
    end
  end

  def slack_client
    @slack_client = Slack::Client.new
  end

  def commit_messages(pull_request)
    name = repo_name(pull_request)
    number = pull_request_number(pull_request)
    commits = client.pull_request_commits(name, number)
    commits.collect do |c|
      c["commit"]["message"]
    end
  end

end



