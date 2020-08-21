# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :dudo,
  ecto_repos: [Dudo.Repo]

# Configures the endpoint
config :dudo, DudoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "bALhm0EtwIq9l4Dg6nBpvBPEDP4b4KEQZNdGxgsMyJ2w3pF5QfgNgYRgBvSGboP/",
  render_errors: [view: DudoWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Dudo.PubSub,
  live_view: [signing_salt: "1vQcglJT"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
