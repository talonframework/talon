defmodule Mix.Tasks.Talon.New do
  @moduledoc """
  Add Talon to an existing Phoenix Project.

      mix talon.install



  ## Project Structure Support

  Both legacy projects created with `mix phoenix.new` and the new project
  structure created with `mix phx.new` are supported. The generator will
  auto-detect the project structure, and if all paths can be correctly
  detected, the install will continue.

  ## Options

  ### Argument Switches

  * --theme=theme_name (admin_lte) -- set the theme to be installed
  * --assets-path (auto detect) -- path to the assets directory
  * --web-path=path (auto detect) -- set the web path

  ### Boolean Options

  * --dry-run (false) -- print what will be done, but don't create any files
  * --verbose (false) -- Print extra information
  * --brunch-instructions-only (false) -- no brunch boilerplate. Print instructions only
  * --brunch (true) -- generate brunch boilerplate
  * --layouts (true) -- include layout views and templates
  * --components (true) -- include component views and templates
  * --generators (true) -- include CRUD eex templates
  * --assets (true) -- include JS, CSS, and Images
  * --assets-only (false) -- generate assets only
  * --layouts-only (false) -- generate layouts only
  * --components-only (false) -- generate components only
  * --generators-only (false) -- generate generators only
  * --brunch-only (false) -- generate brunch only
  * --theme (true) -- generate the theme, assets, brunch

  To disable a default boolean option, use the `--no-option` syntax. For example,
  to disable brunch:

      mix talon.new --no-brunch

  """
  use Mix.Task

  import Mix.Talon
  # import Mix.Generator

  @default_theme "admin_lte"

  # list all supported boolean options
  @boolean_options ~w(all_themes verbose boilerplate dry_run no_assets)a  ++
                   ~w(no_brunch phx phoenix)a

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

    opts
    |> parse_options(parsed)
    |> do_config(args)
    |> do_run
  end

  defp do_run(config) do
    log config, inspect(config), label: "config"
    config
    |> gen_config
    |> verify_project!
    |> gen_talon_context
    |> gen_controller
    |> gen_page_controller
    |> gen_dashboard_page
    |> gen_web
    |> gen_messages
    |> gen_theme
    |> add_compiler
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
      |> append_template_engine(contents =~ "PhoenixSlime.Engine")
      |> append_talon_config(fname, contents =~ fname)

    config
  end

  defp append_talon_config(contents, _, true), do: contents
  defp append_talon_config(contents, fname, _) do
    contents <> "\n" <> ~s(import_config "#{fname}") <> "\n\n"
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

  def gen_controller(config) do     # TODO: use gen_resource_controller (DJS)
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

  def gen_page_controller(config) do
    fname = "talon_page_controller.ex"
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

  defp gen_dashboard_page(%{dashboard: true} = config) do
    binding = Kernel.binding() ++ [base: config.base, page: "Dashboard", boilerplate: config[:boilerplate]]
    source_path = "priv/templates/talon.new/talon"
    target_path = "lib/#{config.app}/talon"
    unless config.dry_run do
      File.mkdir_p! target_path
      copy_from paths(), source_path, target_path, binding, [{:eex, "page.ex", "dashboard.ex"}], config
    end
   config
  end
  defp gen_dashboard_page(config), do: config

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
    fname = "talon_messages.ex"
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

  defp gen_theme(config) do
    Mix.Tasks.Talon.Gen.Theme.run([@default_theme, @default_theme] ++ config.raw_args)
    config
  end

  defp add_compiler(config) do
    case File.read "mix.exs" do
      {:ok, contents} ->
        config
        |> add_compiler("mix.exs", contents)
        |> Map.put(:compiler_generated, :true)
      _ ->
        Mix.shell.info "Could not read mix.exs"
        config
    end
  end

  defp add_compiler(config, path, contents) do
    unless Regex.match? ~r/compilers:\s+\[.*:talon.*\]/, contents do
      contents = String.replace(contents, ~r/compilers:\s+\[(.+)\]/, "compilers: [:talon, \\1]")
      File.write path, contents
    end
    config
  end

  def print_instructions(config) do
    config
    |> print_paging_instructions
    |> print_route_instructions
    |> print_compiler_notice
  end

  defp print_compiler_notice(%{compiler_generated: true} = config) do
    Mix.shell.info "The :talon compiler has been added to your mix.exs file."
    config
  end
  defp print_compiler_notice(config), do: config

  defp print_paging_instructions(config) do
    base = config.base

    Mix.shell.info """

    Add Scrivener paging to your Repo:

    defmodule #{base}.Repo do
      use Ecto.Repo, otp_app: :#{String.downcase base}
      use Scrivener, page_size: 15  # <--- add this
    end
    """
    config
  end

  defp print_route_instructions(config) do
    namespace =
      if config.project_structure == :phx do
        "#{config.base}.Web"
      else
        config.base
      end

    Mix.shell.info """

    Add the talon routes to your web/router.ex:

      use Talon.Router

      # your app's routes
      scope "/talon", #{namespace} do
        pipe_through :browser
        talon_routes()
      end
    """
    config
  end

  defp do_config({bin_opts, opts, _parsed} = args, raw_args) do
    binding =
      Mix.Project.config
      |> Keyword.fetch!(:app)
      |> Atom.to_string
      |> Mix.Phoenix.inflect

    proj_struct =
      cond do
        opts[:proj_struct] -> String.to_atom(opts[:proj_struct])
        bin_opts[:phx] -> :phx
        bin_opts[:phoenix] -> :phoenix
        true -> detect_project_structure()
      end

    %{
      raw_args: raw_args,
      themes: get_themes(args),
      theme: opts[:theme] || @default_theme,
      verbose: bin_opts[:verbose],
      dry_run: bin_opts[:dry_run],
      dashboard: true, # TODO: bin_opts[:dashboard] || Application.get_env(:talon, :dashboard, true), (DJS)
      package_path: get_package_path(),
      app: Mix.Project.config |> Keyword.fetch!(:app),
      project_structure: proj_struct,
      web_namespace: web_namespace(proj_struct),
      web_path: web_path(),
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

  defp paths do
    [".", :talon]
  end
end
