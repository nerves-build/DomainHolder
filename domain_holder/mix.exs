defmodule DomainHolder.MixProject do
  use Mix.Project
  @all_targets [:rpi0, :rpi3]

  def project do
    [
      app: :domain_holder,
      version: "1.0.0",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {DomainHolder.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.3"},
      {:phoenix_live_view, github: "phoenixframework/phoenix_live_view"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_html, "~> 2.13"},
      {:phoenix_ecto, "~> 4.0"},
      {:uuid, "~> 1.1"},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false},
      {:pigpiox, "~> 0.1", targets: @all_targets, override: true},
      {:nerves_neopixel, "~> 0.4", targets: @all_targets, override: true},
      {:blink_o_meter, "~> 1.0"},
      {:ecto_sql, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"}
    ]
  end
end
