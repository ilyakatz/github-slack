
Send messages from a Slack channel into Github pull requests

Validate that branch name of a pull request has Pivotal ID
![Alt text](https://monosnap.com/file/jGbqtewAMsYC7xTe5XmN8jgJ17CWOg.png)

Warn developers if there is message the group in the Slack room
![Alt text](https://monosnap.com/file/YrPXgXfSVWhtasbrgUxyz5UAdHx39e.png)

# Github repo config

Configuration of hooks can be access in the repo settings

![Alt text](https://monosnap.com/file/NxqohNVLATwCjz1iWXPHULW380BVnR.png)

# Install

## Tokens

Generate a new Github token

https://github.com/settings/tokens/new

With `repo` scopes

## Local

```
gem install bundler

bundle install
```

https://github.com/settings/tokens

```
export MY_PERSONAL_TOKEN=5aa5e7.......d5139f

bundle exec ruby deployer.rb

```

# Sample request

You can run sample requests manually using Postman

![Alt text](https://monosnap.com/file/0JFDd38uJT6nOHTk1wWKa89JNX0h1h.png)

Directory `samples/` contains sample requests for each `X-GitHub-Event`

# Deploy

`git push heroku master`

# Docker

## Start the environment

```
docker-machine start dev
eval "$(docker-machine env dev)"
docker build -t execonline-inc/github-integrations .
docker run -p 4567:4567 execonline-inc/github-integrations
```

Application will run on

`docker-machine ip dev`:4567

## Deploy on ECS

https://aws.amazon.com/getting-started/tutorials/deploy-docker-containers/
http://blog.honeybadger.io/how-to-deploy-a-sinatra-app-in-docker-to-amazon-s-ec2-container-service/

```
docker push 738984711291.dkr.ecr.us-east-1.amazonaws.com/github-integrations:latest
```
