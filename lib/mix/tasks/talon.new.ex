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

  * --theme=theme_name (admin-lte) -- set the theme to be installed
  * --assets-path (auto detect) -- path to the assets directory
  * --concern=(Admin) -- set the concern module name
  * --root-path=(lib/my_app/talon) - the path where talon files are stored
  * --path_prefix=("") -- the path prefix for `controllers`, `templates`, `views`

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


  # list all supported boolean options
  @boolean_options ~w(all_themes verbose boilerplate dry_run no_assets)a  ++
                   ~w(no_brunch phx phoenix)a

  @enabled_boolean_options ~w(brunch assets layouts generators components theme)a

  @all_boolean_options @boolean_options ++ @enabled_boolean_options

  # complete list of supported options
  @switches [
    theme_name: :string, concern: :string, root_path: :string, path_prefix: :string
  ] ++ Enum.map(@all_boolean_options, &({&1, :boolean}))

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
    |> gen_talon_concern
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
    concern_config_path = Application.app_dir(:talon,
      "priv/templates/talon.new/config/concern_config.exs")
    binding = Kernel.binding() ++ [config: config, theme: config.theme_name,
      path: concern_config_path
    ]
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

  def gen_talon_concern(config) do
    concern_path = Inflex.underscore(config.concern)
    fname = concern_path <> ".ex"
    binding = Kernel.binding() ++ [base: config.base, app: config.app,
      boilerplate: config.boilerplate, concern: to_s(config.concern)]
    target_path = Path.join config.root_path, concern_path
    unless config.dry_run do
      copy_from paths(),
        "priv/templates/talon.new/web", target_path, binding, [
          {:eex, "talon_concern.ex", fname},
        ], config
    end
   config
  end

  def gen_controller(config) do
    fname = "resource_controller.ex"
    target_fname = Inflex.underscore(config.concern) <> "_" <> fname
    web_module = web_module config.web_namespace
    layout = Module.concat([config.base, config.concern, config.theme_module,
      web_module, LayoutView])
    layout = ~s/{#{layout}, "app.html"}/
    binding = Kernel.binding() ++ [base: config.base, web_base: config.web_base, concern: config.concern,
      boilerplate: config[:boilerplate], web_namespace: config.web_namespace,
      layout: layout, web_module: web_module]
    target_path = Path.join([config.root_path, "controllers", config.path_prefix])
    unless config.dry_run do
      File.mkdir_p! target_path
      copy_from paths(),
        "priv/templates/talon.new/web/controllers", target_path, binding, [
          {:eex, fname, target_fname},
        ], config
    end
   config
  end

  def gen_page_controller(config) do
    fname = "page_controller.ex"
    target_fname = Inflex.underscore(config.concern) <> "_" <> fname
    web_module = web_module config.web_namespace
    layout = Module.concat([config.base, config.concern, config.theme_module,
      web_module, LayoutView])
    layout = ~s/{#{layout}, "app.html"}/  # TODO: DJS handle layout
    binding = Kernel.binding() ++ [base: config.base, web_base: config.web_base, concern: config.concern,
      boilerplate: config[:boilerplate], web_namespace: config.web_namespace,
      layout: layout, web_module: web_module]
    target_path = Path.join([config.root_path, "controllers", config.path_prefix])
    unless config.dry_run do
      File.mkdir_p! target_path
      copy_from paths(),
        "priv/templates/talon.new/web/controllers", target_path, binding, [
          {:eex, fname, target_fname},
        ], config
    end
   config
  end

  defp gen_dashboard_page(%{dashboard: true} = config) do
    concern_path = Inflex.underscore(config.concern)
    binding = Kernel.binding() ++ [base: config.base, page: "Dashboard",
      boilerplate: config[:boilerplate], concern: to_s(config.concern)]
    source_path = "priv/templates/talon.new/talon"
    target_path = Path.join config.root_path, concern_path
    unless config.dry_run do
      File.mkdir_p! target_path
      copy_from paths(), source_path, target_path, binding, [{:eex, "page.ex", "dashboard.ex"}], config
    end
   config
  end
  defp gen_dashboard_page(config), do: config

  def gen_web(config) do
    fname = "talon_web.ex"
    theme = config.theme_name
    binding = Kernel.binding() ++
      [base: config.base, web_base: config.web_base, web_namespace: config.web_namespace, theme: theme,
        theme_module: Inflex.camelize(theme), root_path: config.root_path,
        path_prefix: config.path_prefix]
    target_path = Path.join config.root_path, config.path_prefix
    unless config.dry_run do
      copy_from paths(),
        "priv/templates/talon.new/web", target_path, binding, [
          {:eex, fname, "web.ex"},
        ], config
    end
   config
  end

  def gen_messages(config) do
    fname = "talon_messages.ex"
    binding = Kernel.binding() ++
      [base: config.base, web_base: config.web_base, web_namespace: config.web_namespace]
    target_path = Path.join config.root_path, config.path_prefix
    unless config.dry_run do
      copy_from paths(),
        "priv/templates/talon.new/web", target_path, binding, [
          {:eex, fname, "messages.ex"},
        ], config
    end
   config
  end

  defp gen_theme(%{theme: true} = config) do
    Mix.Tasks.Talon.Gen.Theme.run(config.raw_args)
    config
  end
  defp gen_theme(config), do: config

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
      use Ecto.Repo, otp_app: :#{config.app}
      use Scrivener, page_size: 15  # <--- add this
    end
    """
    config
  end

  defp print_route_instructions(config) do
    full_concern = Module.concat config.base, config.concern

    route_scope = Inflex.underscore(config.concern)

    Mix.shell.info """

    Add the talon routes to your web/router.ex:

      use Talon.Router

      # your app's routes
      scope "/#{route_scope}", #{config.web_base} do
        pipe_through :browser
        talon_routes(#{to_s full_concern})
      end
    """
    config
  end

  defp do_config({bin_opts, opts, _parsed} = args, raw_args) do

    {concern, theme_name} = process_concern_theme(opts)

    target_name = Keyword.get(opts, :target_theme, theme_name)
    target_module = Inflex.camelize(target_name)

    binding =
      Mix.Project.config
      |> Keyword.fetch!(:app)
      |> Atom.to_string
      |> Mix.Phoenix.inflect

    proj_struct = to_atom(opts[:proj_struct] || detect_project_structure())

    app = opts[:app_name] || Mix.Project.config |> Keyword.fetch!(:app)
    app_path_name = app |> to_string |> Inflex.underscore
    root_path = opts[:root_path] || Path.join(["lib", app_path_name, default_root_path()])

    bin_opts
    |> enabled_bin_options
    |> Enum.into(
      %{
        raw_args: raw_args,
        root_path: root_path,
        path_prefix: opts[:path_prefix] || default_path_prefix(),
        themes: get_themes(args),
        theme_name: target_name,
        theme_module: target_module,
        concern: concern,
        verbose: bin_opts[:verbose],
        dry_run: bin_opts[:dry_run],
        dashboard: true, # TODO: bin_opts[:dashboard] || Application.get_env(:talon, :dashboard, true), (DJS)
        package_path: get_package_path(),
        app: app,
        app_path_name: app_path_name,
        project_structure: proj_struct,
        web_namespace: web_namespace(proj_struct),
        binding: binding,
        boilerplate: bin_opts[:boilerplate] || Application.get_env(:talon, :boilerplate, true),
        base: bin_opts[:module] || binding[:base],
        web_base: web_base(bin_opts[:module] || binding[:base], proj_struct),
      })
  end

  defp to_atom(atom) when is_atom(atom), do: atom
  defp to_atom(string), do: String.to_atom(string)

  defp enabled_bin_options(bin_opts) do
    @enabled_boolean_options
    |> Enum.reduce(%{}, fn option, acc ->
      value = if bin_opts[option] == false, do: false, else: true
      Map.put acc, option, value
    end)
  end

  defp get_themes({opts, bin_opts, _parsed}) do
    cond do
      bin_opts[:all_themes] -> all_themes()
      opts[:theme] -> [opts[:theme]]
      all = all_themes() -> Enum.take(all, 1)
    end
  end

  defp all_themes do
    Application.get_env :talon, :themes, [default_theme()]
  end

  defp parse_options([], parsed) do
    {[], [], parsed}
  end
  defp parse_options(opts, parsed) do
    bin_opts = Enum.filter(opts, fn {k,_v} -> k in @all_boolean_options end)
    {bin_opts, opts -- bin_opts, parsed}
  end

  defp paths do
    [".", :talon]
  end
end
