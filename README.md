# Find Me a Parking Spot

## CI/CD workflow
*(Work in Progress)*

Build, Test & Deploy pipeline is implemented via Github Workflows (see ```.github/workflows``` directory).

For hosting, Heroku was initially considered, but [Phoenix docs recommend Gigalixir instead] (https://hexdocs.pm/phoenix/heroku.html#limitations).

The workflow is set up in such a way that, whenever a push is made on any branch, the ```build_test``` job will run on the new code and logged in the "Actions" tab. Internally this sets up a container, installs dependencies, sets up a test db and runs ```mix test```. 

To merge into main, a PR must be opened and all pipeline checks must pass.

Once a PR is accepted and merged, the ```gigalixir``` job will run and deploy the latest code in main branch to Gigalixir.


Prod URL: 
https://organic-intrepid-bactrian.gigalixirapp.com/


## Running locally:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

