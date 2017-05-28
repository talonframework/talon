defmodule Talon.TestHelpers do

  @phx_web_path "lib/blogger/web"
  @phoenix_web_path "web"

  @phx_assets_path "assets"
  @phoenix_assets_path Path.join("web", "static")

  @brunch_file """
  // Test brunch-config.js file

  """

  def mk_phoenix_project do
    mk_web_path @phoenix_web_path
    mk_assets_path @phoenix_assets_path
    mk_brunch_file :phoenix
    mk_mix_file()
    mk_config_file()
  end

  def mk_phx_project do
    mk_web_path()
    mk_assets_path()
    mk_brunch_file :phx
    mk_mix_file()
    mk_config_file()
  end

  def mk_config_file do
    File.mkdir "config"
    File.touch "config/config.exs"
  end

  def mk_mix_file do
    File.write "mix.exs", mix_exs()
  end

  def mk_web_path(path \\ @phx_web_path) do
    File.mkdir_p!(path)
  end

  def mk_assets_path(path \\ @phx_assets_path) do
    File.mkdir_p!(path)
  end

  def mk_brunch_file(mode) do
    path = brunch_path(mode)
    File.mkdir_p path
    File.write brunch_file(mode), @brunch_file
  end

  def assets_path(path, which \\ :phx)
  def assets_path(path, :phx), do: Path.join(@phx_assets_path, path)
  def assets_path(path, _), do: Path.join(@phoenix_assets_path, path)

  def brunch_path(:phx), do: "assets"
  def brunch_path(_), do: ""


  # defp phoenix_config(opts \\ []) do
  #   Enum.into opts, @default_phoenix_config
  # end

  # defp phx_config(opts \\ []) do
  #   Enum.into opts, @default_phx_config
  # end

  def brunch_file(mode) do
    mode
    |> brunch_path
    |> Path.join("brunch-config.js")
  end

  def mix_exs, do: """
    defmodule Blogger.Mixfile do
      use Mix.Project

      def project do
        [app: :blogger,
         version: "0.0.1",
         elixir: "~> 1.4",
         elixirc_paths: elixirc_paths(Mix.env),
         compilers: [:phoenix, :gettext] ++ Mix.compilers,
         start_permanent: Mix.env == :prod,
         aliases: aliases(),
         deps: deps()]
      end
    end
    """
end
