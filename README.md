## To run JobHunter

- Create facebook dev acount

- set a few environment variables:
  - export DUUNTORI_TOKEN=<duuntori_api_token>
  - export ACCESS_TOKEN=<facebook_dev_token>
  - export APP_SECRET=<facebook_app_secret>
  - export VERIFY_TOKEN=<facebook_verify_token>

- Open one terminal and start ngrok to listent to localhost and get facebook callbacks:

`ngrok http 80`

- Set the allowed callback urls in facebook developer settings

- Open another terminal and run bundler

`bundle install`

- Start your rails server

`rails s`

- Open another terminal and run the cron task

`bundle exec crono RAILS_ENV=development`

- Visit localhost:3000