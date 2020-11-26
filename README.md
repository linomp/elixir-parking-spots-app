# Find Me a Parking Spot

## Deployed App

The app is live! 

Check it out at: 
https://organic-intrepid-bactrian.gigalixirapp.com/


## Project Tracking
[Link to our Jira project](https://agile-final-project.atlassian.net/secure/RapidBoard.jspa?rapidView=1&view=planning&selectedIssue=FMPS-4&issueLimit=100)

## Running locally

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Run `mix ecto.reset` (will wipe all data).  Alternatively, `mix ecto.migrate`
  * To run the app: `mix phx.server`
  
  
  **Note:**
  * Whenever you need to seed your local db: `mix run priv/repo/seeds.exs`
 
## Unit Tests
  * Run `MIX_ENV=test mix test`
  
## BDD Tests
  * Start `chromedriver` in a separate terminal window
  * Run `MIX_ENV=test mix ecto.reset`
  * Run `MIX_ENV=test mix white_bread.run`
 
  
## Headless BDD Testing alternative (phantomJS)
* **Headless is faster**; BDD without opening the browser.
* Download phantomjs executable just like `chrome_driver`: https://phantomjs.org/download.html
* Run phantom in a separate terminal window: `phantomjs --wd`
* in `config/test.exs` replace this line:
  ```
  config :hound, driver: "chrome_driver"
  ```
  with this:
  ```
  config :hound, driver: "phantomjs"
  ```


## CI/CD pipeline

Build, Test & Deploy pipeline is implemented via Github Actions (see ```.github/workflows``` directory).

For hosting, Heroku was initially considered, but [Phoenix docs recommend Gigalixir instead](https://hexdocs.pm/phoenix/heroku.html#limitations).

The pipeline is set up in such a way that, whenever a push is made on any branch, the ```build_test``` job will run (logs can be seen in the "Actions" tab). 

Internally this sets up a container, installs dependencies, sets up a test db and runs ```mix test```. 

To merge into main, a PR must be opened and all pipeline checks must pass.

Once a PR is accepted and merged into ```main```, the ```gigalixir``` job will run and deploy the latest code in ```main``` branch to Gigalixir.



Our sources:

- [Github Actions + Phoenix CI/CD](https://www.mitchellhanberg.com/ci-cd-with-phoenix-github-actions-and-gigalixir/) (starting point, but had its issues)
- [Phoenix docs - manually deploy app to Gigalixir](https://hexdocs.pm/phoenix/gigalixir.html#content)
- [Gigalixir deploy job gist](https://gist.github.com/jesseshieh/7b231370874445592a40bf5ed6961460)
