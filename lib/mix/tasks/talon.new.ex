defmodule Mix.Tasks.Talon.New do
  @moduledoc """
  Add Talon to an existing Phoenix Project.

      mix talon.install

  Creates the following files:

  * web/views/talon/admin_lte path
  * web/controllers/talon/talon_resource_controller.ex
  * web/templates/talon/admin_lte/generators path
    * edit.html.eex
    * form.html.eex
    * index.html.eex
    * new.html.eex
    * show.html.eex
  * lib/my_app/talon/talon.ex
  * config/talon.exs
  * assets_path/vendor

  ## Options

  * --no-brunch
  * --no-assets
  * --theme=custom_theme -- create the layout file for a custom theme
  * --all-themes -- create the layout for all configured themes
  * --dry-run -- print what will be done, but don't create any files
  * --verbose -- Print extra information
  """
  use Mix.Task

  import Mix.Talon
  # import Mix.Generator

  @default_theme "admin_lte"

  # list all supported boolean options
  @boolean_options ~w(all_themes verbose boilerplate dry_run no_assets no_brunch)a

  # complete list of supported options
  @switches [
    theme: :string
  ] ++ Enum.map(@boolean_options, &({&1, :boolean}))


  @doc """
  The entry point of the mix task.
  """
  @spec run(List.t) :: any
  def run(args) do
    {opts, parsed, _unknown} = OptionParser.parse(args, switches: @switches)

    # TODO: Add args verification
    # verify_args!(parsed, unknown)
    opts
    |> parse_options(parsed)
    |> do_config
    |> do_run
  end

  defp do_run(config) do
    log config, inspect(config), label: "config"
    config
    |> gen_config
    |> verify_project!
    |> gen_talon_context
    |> gen_controller
    |> gen_web
    |> gen_messages
    |> gen_theme
    |> print_instructions
  end

  def verify_project!(config) do
    unless File.exists?("config/config.exs"), do: Mix.raise("Can't find config/config.exs")
    config
  end

  def gen_config(config) do
    fname = "talon.exs"
    binding = Kernel.binding() ++ [base: config.base, theme: config.theme,
      web_namespace: config.web_namespace]
    unless config.dry_run do
      copy_from paths(),
        "priv/templates/talon.new/config", "config", binding, [
          {:eex, fname, fname},
        ], config
    end

    path = "config/config.exs"

    contents = File.read!(path)

    File.write path,
      contents
      |> append_talon_config(fname, contents =~ fname)
      |> append_template_engine(contents =~ "PhoenixSlime.Engine")

    config
  end

  defp append_talon_config(contents, _, true), do: contents
  defp append_talon_config(contents, fname, _) do
    contents <> "\n" <> ~s(import_config "#{fname}") <> "\n"
  end

  defp append_template_engine(contents, true), do: contents
  defp append_template_engine(contents, _) do
    contents <> """
      config :phoenix, :template_engines,
        slim: PhoenixSlime.Engine,
        slime: PhoenixSlime.Engine
      """
  end

  def gen_talon_context(config) do
    fname = "talon.ex"
    binding = Kernel.binding() ++ [base: config.base, app: config.app, boilerplate: config.boilerplate]
    target_path = "lib/#{config.app}/talon"
    unless config.dry_run do
      File.mkdir_p! target_path
      copy_from paths(),
        "priv/templates/talon.new/lib", target_path, binding, [
          {:eex, "talon_context.ex", fname},
        ], config
    end
   config
  end

  def gen_controller(config) do
    fname = "talon_resource_controller.ex"
    binding = Kernel.binding() ++ [base: config.base,
      boilerplate: config[:boilerplate], web_namespace: config.web_namespace]
    target_path = Path.join([config.web_path, "controllers", "talon"])
    unless config.dry_run do
      File.mkdir_p! target_path
      copy_from paths(),
        "priv/templates/talon.new/web/controllers", target_path, binding, [
          {:eex, fname, fname},
        ], config
    end
   config
  end

  def gen_web(config) do
    fname = "talon_web.ex"
    theme = config.theme
    binding = Kernel.binding() ++
      [base: config.base, web_namespace: config.web_namespace, theme: theme,
        theme_module: Inflex.camelize(theme), web_path: config.web_path]
    target_path = config.web_path
    unless config.dry_run do
      File.mkdir_p! target_path
      copy_from paths(),
        "priv/templates/talon.new/web", target_path, binding, [
          {:eex, fname, fname},
        ], config
    end
   config
  end

  def gen_messages(config) do
    fname = "messages.ex"
    binding = Kernel.binding() ++
      [base: config.base, web_namespace: config.web_namespace]
    target_path = config.web_path
    unless config.dry_run do
      File.mkdir_p! target_path
      copy_from paths(),
        "priv/templates/talon.new/web", target_path, binding, [
          {:eex, fname, fname},
        ], config
    end
   config
  end

  def gen_theme(config) do
    opts = if config[:verbose], do: ["--verbose"], else: []
    opts = if config[:dry_run], do: ["--dry-run" | opts], else: opts

    Mix.Tasks.Talon.Gen.Theme.run([@default_theme, @default_theme] ++ opts)
    config
  end

  def print_instructions(config) do
    Mix.shell.info """
      TBD...
      """
    config
  end

  defp do_config({bin_opts, opts, _parsed} = args) do
    binding =
      Mix.Project.config
      |> Keyword.fetch!(:app)
      |> Atom.to_string
      |> Mix.Phoenix.inflect

    proj_struct = detect_project_structure()

    %{
      themes: get_themes(args),
      theme: opts[:theme] || @default_theme,
      verbose: bin_opts[:verbose],
      dry_run: bin_opts[:dry_run],
      package_path: get_package_path(),
      app: Mix.Project.config |> Keyword.fetch!(:app),
      project_structure: proj_struct,
      web_namespace: web_namespace(proj_struct),
      web_path: web_path(verify: true),
      binding: binding,
      boilerplate: bin_opts[:boilerplate] || Application.get_env(:talon, :boilerplate, true),
      base: bin_opts[:module] || binding[:base],
    }
  end

  defp get_themes({opts, bin_opts, _parsed}) do
    cond do
      bin_opts[:all_themes] -> all_themes()
      opts[:theme] -> [opts[:theme]]
      all = all_themes() -> Enum.take(all, 1)
    end
  end

  defp all_themes do
    Application.get_env :talon, :themes, [@default_theme]
  end

  defp parse_options([], parsed) do
    {[], [], parsed}
  end
  defp parse_options(opts, parsed) do
    bin_opts = Enum.filter(opts, fn {k,_v} -> k in @boolean_options end)
    {bin_opts, opts -- bin_opts, parsed}
  end

  # defp lib_path do
  #   Path.join("lib", to_string(Mix.Phoenix.otp_app()))
  # end

  defp paths do
    [".", :talon]
  end
end
