defmodule Fw.MixProject do
  use Mix.Project

  @all_targets [:rpi0, :rpi3]
  @app :fw

  def project do
    [
      app: :fw,
      version: "1.0.0",
      elixir: "~> 1.9",
      archives: [nerves_bootstrap: "~> 1.0"],
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.target() != :host,
      aliases: [loadconfig: [&bootstrap/1]],
      releases: [{@app, release()}],
      deps: deps()
    ]
  end

  # Starting nerves_bootstrap adds the required aliases to Mix.Project.config()
  # Aliases are only added if MIX_TARGET is set.
  def bootstrap(args) do
    Application.start(:nerves_bootstrap)
    Mix.Task.run("loadconfig", args)
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Fw.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nerves, "~> 1.5.0", runtime: false},
      {:shoehorn, "~> 0.6"},
      {:ring_logger, "~> 0.6"},
      {:toolshed, "~> 0.2"},
      {:dynu_reporter, "~> 1.0.1"},
      {:nerves_runtime, "~> 0.6", targets: @all_targets},
      {:nerves_network, "~> 0.5", targets: @all_targets},
      {:domain_holder, path: "../domain_holder"},
      {:nerves_init_gadget, "~> 0.5", targets: @all_targets},
      {:nerves_time, "~> 0.2", targets: @all_targets},

      # Dependencies for specific targets
      {:nerves_system_rpi0, "~> 1.8", runtime: false, targets: :rpi0},
      {:nerves_system_rpi3, "~> 1.8", runtime: false, targets: :rpi3}
    ]
  end

  def release do
    [
      overwrite: true,
      cookie: "#{@app}_cookie",
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble],
      strip_beams: Mix.env() == :prod
    ]
  end
end
