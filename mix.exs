defmodule ExAdmin.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_admin,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger],
     mod: {ExAdmin.Application, [:inflex]}]
  end

  defp deps do
    [
      {:inflex, "~> 1.7"},
    ]
  end
end
