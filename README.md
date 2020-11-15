# Find Me a Parking Spot

## CI/CD pipeline

Build, Test & Deploy pipeline is implemented via Github Actions (see ```.github/workflows``` directory).

For hosting, Heroku was initially considered, but [Phoenix docs recommend Gigalixir instead](https://hexdocs.pm/phoenix/heroku.html#limitations).

The pipeline is set up in such a way that, whenever a push is made on any branch, the ```build_test``` job will run (logs can be seen in the "Actions" tab). 

Internally this sets up a container, installs dependencies, sets up a test db and runs ```mix test```. 

To merge into main, a PR must be opened and all pipeline checks must pass.

Once a PR is accepted and merged into ```main```, the ```gigalixir``` job will run and deploy the latest code in ```main``` branch to Gigalixir.

Check out the deployed app at: 
https://organic-intrepid-bactrian.gigalixirapp.com/



Our sources:

- [Github Actions + Phoenix CI/CD](https://www.mitchellhanberg.com/ci-cd-with-phoenix-github-actions-and-gigalixir/) (starting point, but had its issues)
- [Phoenix docs - manually deploy app to Gigalixir](https://hexdocs.pm/phoenix/gigalixir.html#content)
- [Gigalixir deploy job gist](https://gist.github.com/jesseshieh/7b231370874445592a40bf5ed6961460)


## Running locally:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

