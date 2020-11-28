use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :fmps, Fmps.Repo,
  username: "postgres",
  password: "postgres",
  database: "fmps_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :fmps, FmpsWeb.Endpoint,
  http: [port: 4001],
  server: true

# Print only warnings and errors during test
config :logger, level: :warn

# Add the following lines at the end of the file
config :hound, driver: "chrome_driver"

# Headless alternative (explore for CI/CD):
# download phantomjs executable just like chrome_driver: https://phantomjs.org/download.html
# run phantom in separate window:   phantomjs --wd
#config :hound, driver: "phantomjs"

config :fmps, sql_sandbox: true
