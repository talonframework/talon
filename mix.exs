defmodule Talon.Mixfile do
  use Mix.Project

  def project do
    [app: :talon,
     version: "0.1.0",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     compilers: compilers(Mix.env),
     deps: deps()]
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
      {:phoenix, "~> 1.3.0-rc"},
      {:phoenix_html, "~> 2.6"},
      {:phoenix_ecto, "~> 3.2"},
      {:scrivener_ecto, "~> 1.1"},
      {:postgrex, ">= 0.0.0", only: :test},
      {:phoenix_slime, "~> 0.9"},
      {:slime, "~> 1.0", override: true},
      {:ecto_talon, github: "talonframework/ecto_talon"},
      {:mix_test_watch, "~> 0.3", only: :dev, runtime: false},
      {:gettext, "~> 0.11", only: :test},
      {:csv, "~> 2.0"},
      # {:ecto_talon, path: "../ecto_talon", only: :test},
    ]
  end
end
