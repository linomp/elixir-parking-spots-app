# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :fmps,
  ecto_repos: [Fmps.Repo]

# Configures the endpoint
config :fmps, FmpsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "TB9k014eEl8Z8QfloufnFSNJQXmpHIU9XpDLEUWAVxCixJNbeWgR0c18+MFQBaxd",
  render_errors: [view: FmpsWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Fmps.PubSub,
  live_view: [signing_salt: "lJ8va1jm"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
