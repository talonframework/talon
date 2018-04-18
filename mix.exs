defmodule Talon.Mixfile do
  use Mix.Project

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

    # if in_umbrella?(File.cwd!), do: base_config ++ umbrella_config, else: base_config TODO: REMOVE

    if talon_in_umbrella?(), do: base_config ++ umbrella_config, else: base_config
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
    # If using umbrella app, need to always include deps used by siblings
    test_env = if talon_in_umbrella?(), do: [:dev, :prod, :test], else: :test

    [
      {:inflex, "~> 1.7"},
      {:phoenix, "~> 1.3.0"},
      {:phoenix_html, "~> 2.6"},
      {:phoenix_ecto, "~> 3.2"},
      {:scrivener_ecto, "~> 1.1"},
      {:phoenix_slime, "~> 0.9"},
      {:slime, "~> 1.0", override: true},
      {:mix_test_watch, "~> 0.3", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev]},
      {:ecto_talon, github: "talonframework/ecto_talon"},
      # {:ecto_talon, path: "../ecto_talon", only: :test},

      {:postgrex, ">= 0.0.0", only: [:dev, :prod, :test]},
      {:gettext, "~> 0.11", only: test_env}
    ]
  end

  def talon_in_umbrella? do
    System.get_env("TALON_IN_UMBRELLA") == "true"
  end

  # From Mix.Phoenix
  # This doesn't work when pulling Talon into an umbrella using a symbolic link
  # TODO: remove
  def in_umbrella?(app_path) do
    umbrella = Path.expand(Path.join [app_path, "..", ".."])
    mix_path = Path.join(umbrella, "mix.exs")
    apps_path = Path.join(umbrella, "apps")
    IO.inspect apps_path, label: "apps_path"
    File.exists?(mix_path) && File.exists?(apps_path)
  end
end
