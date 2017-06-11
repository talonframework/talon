defmodule Mix.Tasks.Talon.Gen.Theme do
  @moduledoc """
  Install a new Talon theme into your project.

      mix talon.gen.theme theme target_namees

  The target theme will contain:

  * CRUD templates generators in `web/templates/talon/target_name/generators
  * Views for of your configured resources in `web/views/talon/target_name`
  * Layout view and templates
  * JS, CSS, and Images for the theme, name spaced by target_name
  * Boilerplate added to your `brunch-config.js` file

  The generator takes 2 arguments plus a number of optional switches as
  described below

  * `theme` - one of the Talon installed themes i.e. `admin_lte`
  * `target_name` - the new name of theme when installed in your project.

  This generator serves three purposes. First, its called automatically
  from the `mix talon.new` mix task to handle the installation of the
  default `admin_lte` theme.

  Secondly, it can be used to install another theme into your project,
  if a second theme is included in the Talon package

      # assuming talon comes with the admin_topnav theme
      mix talon.gen.theme admin_topnav admin_topnav

  Lastly, it can be used to create a theme template to assist in building
  your own custom theme.

      mix talon.gen.theme admin_lte my_theme

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

  To disable a default boolean option, use the `--no-option` syntax. For example,
  to disable brunch:

      mix talon.gen.theme admin_lte my_theme --no-brunch
  """
  use Mix.Task

  import Mix.Talon
  import Talon.Gettext

  @only_options_options  ~w(assets layouts components generators brunch)
  @only_options for only <-@only_options_options, do: only <> "_only"

  # list all supported boolean options
  @boolean_options ~w(all_themes verbose boilerplate dry_run phx phoenix)a ++
                   ~w(brunch_instructions_only)

  # List of the options that default to yet
  @enabled_boolean_options ~w(brunch assets layouts generators components dashboard)

  # All the boolean options
  @all_boolean_options @boolean_options ++ @enabled_boolean_options ++ @only_options

  # complete list of supported options
  @switches [
    theme: :string,
    web_path: :string,
    assets_path: :string,
    module: :string
  ] ++ Enum.map(@all_boolean_options, &({&1, :boolean}))

  @default_theme "admin_lte"

  # Two paths are required here. The relative path is used when when we
  # call `copy_from` since it calculates the absolute path based on the
  # app name (:talon). The `@source_path` is an absolute path for reading
  # files from priv before calling `copy_path`.
  @source_path_relative Path.join(~w(priv templates talon.gen.theme))
  @source_path Path.join(Application.app_dir(:talon), @source_path_relative)

  # TODO: Move this to a theme config file.
  # Two item tuple. First element is the relative path. Second element is a
  # list of files in that path
  @admin_lte_files [
    {"vendor/talon/admin-lte/plugins/jQuery", ["jquery-2.2.3.min.js"]},
    {"vendor/talon/admin-lte/bootstrap/js", ["bootstrap.min.js"]},
    {"vendor/talon/admin-lte/dist/js", ["app.min.js"]},
    {"css/talon/admin-lte", ["talon.css"]},
    {"js/talon/admin-lte", ["talon.js"]},
    {"vendor/talon/admin-lte/dist/css/skins", ["all-skins.css"]},
    {"vendor/talon/admin-lte/bootstrap/css", ["bootstrap.min.css"]},
    {"vendor/talon/admin-lte/dist/css", ["AdminLTE.min.css"]},
    {"vendor/talon/admin-lte/plugins/sweetalert/dist", ["sweetalert.min.js"]},
    {"vendor/talon/admin-lte/plugins/sweetalert/dist", ["sweetalert.css"]},
  ]

  # look for theme name to its list of assets
  @vendor_files %{"admin_lte" =>  @admin_lte_files}

  # translation of of theme name to its resources name space. This list
  # must contain an entry for every installed theme
  @theme_mapping %{"admin_lte" => "admin-lte"}

  @doc false
  @spec run(List.t) :: any
  def run(args) do
    Mix.shell.info "Running talon.gen.theme"
    {opts, parsed, _unknown} = OptionParser.parse(args, switches: @switches)

    # TODO: Add args verification
    opts
    # |> verify_args!(parsed, unknown)
    |> parse_options(parsed)
    |> do_config
    |> do_run
  end

  defp do_run(config) do
    log config, inspect(config), label: "config"
    config
    |> assets_paths
    |> gen_layout_view
    |> gen_layout_templates
    |> gen_dashboard_template
    |> gen_dashboard_view
    |> gen_generators
    |> gen_images
    |> gen_vendor
    |> gen_components
    |> verify_brunch
    |> gen_brunch_boilerplate
    |> print_instructions
  end

  defp gen_components(%{components: true} = config) do
    opts = if config[:verbose], do: ["--verbose"], else: []
    opts = if config[:dry_run], do: ["--dry-run" | opts], else: opts
    opts = ["--web-path=#{config.web_path}", "--proj-struct=#{config.project_structure}" | opts]

    Mix.Tasks.Talon.Gen.Components.run([@default_theme] ++ opts)
    config
  end
  defp gen_components(config), do: config

  defp gen_layout_view(%{layouts: true} = config) do
    binding = Kernel.binding() ++ [base: config.base, target_name: config.target_name,
      target_module: config.target_module, web_namespace: config.web_namespace,
      view_opts: config.view_opts]
    theme = config.theme
    view_path = Path.join([config.web_path, "views", "talon", config.target_name])
    unless config.dry_run do
      File.mkdir_p! view_path
      copy_from paths(),
        "priv/templates/talon.gen.theme/#{theme}/views", view_path, binding, [
          {:eex, "layout_view.ex", "layout_view.ex"}
        ], config
    end
    config
  end
  defp gen_layout_view(config), do: config

  defp gen_layout_templates(%{layouts: true} = config) do
    binding = Kernel.binding() ++ [web_namespace: config.web_namespace, target_name: config.target_name]
    theme = config.theme
    template_path = Path.join([config.web_path, "templates", "talon", config.theme, "layout"])
    unless config.dry_run do
      File.mkdir_p! template_path
      copy_from paths(),
        "priv/templates/talon.gen.theme/#{theme}/templates/layout", template_path, binding, [
          {:eex, "app.html.slim", "app.html.slim"},
          {:eex, "nav_action_link.html.slim", "nav_action_link.html.slim"},
          {:eex, "nav_resource_link.html.slim", "nav_resource_link.html.slim"},
          {:eex, "sidebar.html.slim", "sidebar.html.slim"}
        ], config
    end
    config
  end
  defp gen_layout_templates(config), do: config

  defp gen_generators(%{generators: true} = config) do
    binding = Kernel.binding() ++ [base: config.base, target_name: config.target_name,
      target_module: config.target_module, web_namespace: config.web_namespace]
    theme = config.theme # TODO: used?
    template_path = Path.join([config.web_path, "templates", "talon", config.theme, "generators"])
    unless config.dry_run do
      File.mkdir_p! template_path
      copy_from paths(),
        "priv/templates/talon.gen.theme/#{theme}/templates/generators", template_path, binding, [
          {:eex, "edit.html.eex", "edit.html.eex"},
          {:eex, "form.html.eex", "form.html.eex"},
          {:eex, "index.html.eex", "index.html.eex"},
          {:eex, "new.html.eex", "new.html.eex"},
          {:eex, "show.html.eex", "show.html.eex"},
        ], config
    end
    config
  end
  defp gen_generators(config), do: config

  def gen_dashboard_template(%{dashboard: true} = config) do
    binding = Kernel.binding() ++
      [title_txt: gettext("Dashboard"),
       welcome_txt: (gettext "Welcome to Talon. This is the default dashboard page."),
       add_txt:  (gettext "To add dashboard sections, checkout 'lib/talon/dashboard.ex'")]
    theme = config.theme
    template_path = Path.join([config.web_path, "templates", "talon", theme, "dashboard"])
    unless config.dry_run do
      File.mkdir_p! template_path
      copy_from paths(),
        "priv/templates/talon.gen.theme/#{theme}/templates/dashboard", template_path, binding, [
          {:eex, "dashboard.html.slim", "dashboard.html.slim"}
        ], config
    end
    config
  end
  def gen_dashboard(config), do: config

  defp gen_dashboard_view(%{dashboard: true} = config) do
    binding = Kernel.binding() ++ [base: config.base, target_name: config.target_name,
      target_module: config.target_module, web_namespace: config.web_namespace,
      view_opts: config.view_opts]
    theme = config.theme
    view_path = Path.join([config.web_path, "views", "talon", config.target_name])
    unless config.dry_run do
      File.mkdir_p! view_path
      copy_from paths(),
        "priv/templates/talon.gen.theme/#{theme}/views", view_path, binding, [
          {:eex, "dashboard_view.ex", "dashboard_view.ex"}
        ], config
    end
    config
  end
  defp gen_dashboard_view(config), do: config

  # this is private, but left as `def` for testing
  @doc false
  def gen_images(%{assets: true} = config) do
    unless config.dry_run do
      theme_name = @theme_mapping[config.theme]
      path = Path.join [config.theme, "assets", "static", "images", "talon", theme_name]
      source_path = Path.join([@source_path, path])
      source_path_relative = Path.join(@source_path_relative, path)
      target_path = Path.join([config.images_path, "talon", config.target_name])

      files =
        source_path
        |> Path.join("*")
        |> Path.wildcard
        |> Enum.map(&Path.basename/1)
        |> Enum.map(& {:text, &1, &1})

      File.mkdir_p! target_path
      copy_from paths(), source_path_relative, target_path, [], files, config
    end
    config
  end
  def gen_images(config), do: config

  # this is private, but left as `def` for testing
  @doc false
  def gen_vendor(%{assets: true} = config) do
    unless config.dry_run do
      source_path = Path.join([@source_path_relative, config.target_name, "assets"])
      target_path = Path.join([config.vendor_parent])

      File.mkdir_p! target_path
      copy_from paths(), source_path, target_path, [target_name: config.target_name],
        theme_asset_files(config.target_name), config
    end
    config
  end
  def gen_vendor(config), do: config

  defp theme_asset_files(theme) do
    @vendor_files[theme]
    |> Enum.map(fn {path, files} ->
      Enum.map(files, fn file ->
        fpath = Path.join(path, file)
        {:eex, fpath, fpath}
      end)
    end)
    |> List.flatten
  end

  defp verify_brunch(%{brunch: true} = config) do
    if File.exists?(config.brunch_path) do
      config
    else
      Enum.into([brunch: false, print_brunch_error: true], config)
    end
  end
  defp verify_brunch(config), do: config |> IO.inspect(label: "no verify")

  defp gen_brunch_boilerplate(%{brunch: true, brunch_path: path} = config) do
    boilerplate = render_brunch_boilerplate(config)
    contents = File.read!(path)
    File.write!(path, contents <> boilerplate)
    config
  end
  defp gen_brunch_boilerplate(config), do: config

  defp print_instructions(config) do
    config
    |> print_brunch_instructions
  end

  defp print_brunch_instructions(%{print_brunch_error: true} = config) do
    instructions = render_brunch_boilerplate(config) #  |> String.replace("\/\/", "  ")
    Mix.shell.info """
    Your brunch-config.js file could not be found. Please update your brunch
    based on these instructions:

    """ <> instructions
    config
  end
  defp print_brunch_instructions(%{brunch: true} = config) do
    Mix.shell.info """
    Boilerplate has been added to your brunch-config.js file. Please review this
    and update your config file appropriately.
    """
    config
  end
  defp print_brunch_instructions(config), do: config

  defp render_brunch_boilerplate(config) do
    proj = config.project_structure
    bindings = [
      root_match: brunch_snippets(proj, :root_match),
      root_path: brunch_snippets(proj, :root_path),
      styles_snippet: brunch_snippets(proj, :styles)
    ]
    EEx.eval_string(brunch_boilerplate(), bindings)
  end
  # this is private, but left as `def` for testing
  @doc false
  defp brunch_boilerplate do
    path = Path.join common_absolute_path(:talon), "brunch_boilerplate.txt"
    case File.read(path) do
      {:ok, contents} -> contents
      _ -> Mix.raise("Could not find #{path} in any sources")
    end
  end

  defp brunch_snippets(:phx, :root_match), do: ""
  defp brunch_snippets(_, :root_match), do: "web\\/static\\/"
  defp brunch_snippets(:phx, :root_path), do: ""
  defp brunch_snippets(_, :root_path), do: "web/static/"
  defp brunch_snippets(:phx, :styles), do: ""
  defp brunch_snippets(_, :styles), do: ~s(,
//       order: {
//         after: ["web/static/css/app.css"] // concat app.css last
//       })


  # TODO: This should probably be pulled out and placed in Talon.Mix
  #       since most of the code is common between all the installers
  @doc false
  def do_config({bin_opts, opts, parsed}) do
    themes = get_available_themes()

    {theme, target_name} =
      case parsed do
        [theme, target] ->
          unless theme in themes,
            do: Mix.raise("Invalid theme name. Choices are #{inspect themes}")
          {theme, target}
        other ->
          Mix.raise "Invalid arguments #{inspect other}"
      end

    binding =
      Mix.Project.config
      |> Keyword.fetch!(:app)
      |> Atom.to_string
      |> Mix.Phoenix.inflect
      # |> IO.inspect(label: "binding")
    proj_struct =
      cond do
        opts[:proj_struct] -> String.to_atom(opts[:proj_struct])
        bin_opts[:phx] -> :phx
        bin_opts[:phoenix] -> :phoenix
        true -> detect_project_structure()
      end

    view_opts = view_opts(theme, proj_struct)

    bin_opts
    |> enabled_bin_options
    |> Enum.into(
      %{
        theme: theme,
        target_name: target_name,
        target_module: theme_module_name(theme),
        verbose: bin_opts[:verbose],
        dry_run: bin_opts[:dry_run],
        project_structure: proj_struct,
        web_namespace: web_namespace(proj_struct),
        web_path: opts[:web_path] || web_path(),
        view_opts: view_opts,
        binding: binding,
        boilerplate: bin_opts[:boilerplate] || Application.get_env(:talon, :boilerplate, true),
        base: opts[:module] || binding[:base],
      })
    |> set_config_onlys(bin_opts)
  end

  defp enabled_bin_options(bin_opts) do
    @enabled_boolean_options
    |> Enum.map(&String.to_atom/1)
    |> Enum.reduce(%{}, fn option, acc ->
      value = if bin_opts[option] == false, do: false, else: true
      Map.put acc, option, value
    end)
  end

  defp set_config_onlys(config, bin_opts) do
    Enum.reduce(@only_options, config, fn opt, acc ->
      atom = String.to_atom(opt)
      if bin_opts[atom] do
        opt
        |> options_to_remove
        |> remove_options(acc)
      else
        acc
      end
    end)
  end

  defp options_to_remove(only_option) do
    option = String.replace(only_option, "_only", "")
    @only_options_options -- [option]
  end

  defp remove_options(remove_options, config) do
    Enum.reduce remove_options, config, fn option, config ->
      Map.put(config, String.to_atom(option), false)
    end
  end

  defp get_available_themes do
    :talon
    |> Application.app_dir("priv/templates/talon.gen.theme/*")
    |> Path.wildcard()
    |> Enum.map(& Path.split(&1) |> List.last)
  end

  # defp all_themes do
  #   Application.get_env :talon, :themes, [@default_theme]
  # end

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

# String.replace(~r/compilers:\s+\[(.+)\]/, "compilers: [:talon, \\1]")
