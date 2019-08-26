# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :domain_holder, prefs_location: "~/root/config.term"

config :domain_holder,
  network_adapter: Nerves.NetworkInterface

# Configures the endpoint
config :domain_holder, DomainHolderWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "G+Ar5Rg+WhKxwKDQVF3Y4hOG7zQliRb/mMXqSmGuTCQANqQDpwZF1uZxgdZRfgQL",
  render_errors: [view: DomainHolderWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: DomainHolder.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "HfpsyY8aJLj52N6xC85CLNKZD5UCrptg"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
