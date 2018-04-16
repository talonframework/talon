defmodule Talon.Mixfile do
  use Mix.Project

  # def project do
  #   [app: :talon,
  #    version: "0.1.0",
  #    elixir: "~> 1.4",
  #    elixirc_paths: elixirc_paths(Mix.env),
  #    build_embedded: Mix.env == :prod,
  #    start_permanent: Mix.env == :prod,
  #    compilers: compilers(Mix.env),
  #    dialyzer: [plt_add_deps: :transitive],
  #    deps: deps()]
  # end

  # Testing out Umbrella approach
  def project do
    base_config = [
      app: :talon,
      version: "0.1.0",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env == :prod,
      compilers: compilers(Mix.env),
      dialyzer: [plt_add_deps: :transitive],
      deps: deps()
    ]

    umbrella_config = [
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
    ]

    if in_umbrella?(File.cwd!), do: base_config ++ umbrella_config, else: base_config
  end

  defp compilers(:test), do: [:phoenix] ++ Mix.compilers
  defp compilers(_), do: nil

  def application do
    [mod: {Talon.Application, [:inflex]},
     extra_applications: [:logger]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [
      {:inflex, "~> 1.7"},
      {:phoenix, "~> 1.3.0"},
      {:phoenix_html, "~> 2.6"},
      {:phoenix_ecto, "~> 3.2"},
      {:scrivener_ecto, "~> 1.1"},
      {:postgrex, ">= 0.0.0", only: :test},
      {:phoenix_slime, "~> 0.9"},
      {:slime, "~> 1.0", override: true},
      {:mix_test_watch, "~> 0.3", only: :dev, runtime: false},
      {:gettext, "~> 0.11", only: :test},
      {:dialyxir, "~> 0.5", only: [:dev]},
      {:ecto_talon, github: "talonframework/ecto_talon"},
      # {:ecto_talon, path: "../ecto_talon", only: :test},
    ]
  end

  # From Mix.Phoenix
  def in_umbrella?(app_path) do
    umbrella = Path.expand(Path.join [app_path, "..", ".."])
    mix_path = Path.join(umbrella, "mix.exs")
    apps_path = Path.join(umbrella, "apps")
    IO.puts apps_path
    File.exists?(mix_path) && File.exists?(apps_path)
  end
end
