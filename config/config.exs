# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :hiit_live, HiitLiveWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ksvM/saHbP15IlG8ZZnYTomr70xLoU0L+fiK30uPkaHqp/j+6r4xiciC6IbmkLjT",
  render_errors: [view: HiitLiveWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: HiitLive.PubSub, adapter: Phoenix.PubSub.PG2]

# live view salt
config :hiit_live, HiitLiveWeb.Endpoint,
  live_view: [
    signing_salt: "3zgiI+OabcLnd0QZ8MOwcpP6q6vW2Y0l"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
