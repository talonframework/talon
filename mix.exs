defmodule ExAdmin.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_admin,
     version: "0.1.0",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger],
     mod: {ExAdmin.Application, [:inflex]}]
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
      {:phoenix_slime, github: "slime-lang/phoenix_slime"},
      # {:ecto_ex_admin, github: "ex-admin/ecto_ex_admin", only: :test},
    ]
  end
end
