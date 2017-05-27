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

  ### Boolean Options

  * --dry-run (false) -- print what will be done, but don't create any files
  * --verbose (false) -- Print extra information
  * --brunch-instructions-only (false) -- no brunch boilerplate. Print instructions only
  * --brunch (true) -- generate brunch boilerplate

  ### Argument Options

  * --theme=theme_name (admin_lte) -- set the theme to be installed
  * --assets-path (auto detect) -- path to the assets directory
  * --web-path=path (auto detect) -- set the web path

  To disable a default boolean option, use the `--no-option` syntax. For example,
  to disable brunch:

      mix talon.gen.theme admin_lte my_theme --no-brunch
  """
  use Mix.Task

  import Mix.Talon
  # import Mix.Generator

  # list all supported boolean options
  @boolean_options ~w(all_themes verbose boilerplate dry_run phx phoenix)a ++
                   ~w(brunch_instructions_only)
  @enabled_boolean_options ~w(brunch assets)

  @all_boolean_options @boolean_options ++ @enabled_boolean_options

  # complete list of supported options
  @switches [
    theme: :string, web_path: :string, assets_path: :string
  ] ++ Enum.map(@all_boolean_options, &({&1, :boolean}))

  @default_theme "admin_lte"
  @source_path_relative Path.join(~w(priv templates talon.gen.theme))
  @source_path Path.join(Application.app_dir(:talon), @source_path_relative)

  # TODO: Move this to a theme config file.
  @admin_lte_files [
    {"vendor/talon/admin-lte/plugins/jQuery", ["jquery-2.2.3.min.js"]},
    {"vendor/talon/admin-lte/bootstrap/js", ["bootstrap.min.js"]},
    {"vendor/talon/admin-lte/dist/js", ["app.min.js"]},
    {"css/talon/admin-lte", ["talon.css"]},
    {"vendor/talon/admin-lte/dist/css/skins", ["all-skins.css"]},
    {"vendor/talon/admin-lte/bootstrap/css", ["bootstrap.min.css"]},
    {"vendor/talon/admin-lte/dist/css", ["AdminLTE.min.css"]},
  ]
  @vendor_files %{"admin_lte" =>  @admin_lte_files}

  @theme_mapping %{"admin_lte" => "admin-lte"}

  @doc """
  The entry point of the mix task.
  """
  @spec run(List.t) :: any
  def run(args) do
    Mix.shell.info "Running talon.gen.theme"
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
    |> assets_paths
    |> gen_layout_view
    |> gen_layout_templates
    |> gen_generators
    |> gen_images
    |> gen_vendor
    # |> gen_brunch
    |> gen_components
    # |> gen_brunch_boilerplate
    |> print_instructions
  end

  defp gen_components(config) do
    opts = if config[:verbose], do: ["--verbose"], else: []
    opts = if config[:dry_run], do: ["--dry-run" | opts], else: opts
    opts = ["--web-path=#{config.web_path}", "--proj-struct=#{config.project_structure}" | opts]

    Mix.Tasks.Talon.Gen.Components.run([@default_theme] ++ opts)
    config
  end

  defp gen_layout_view(config) do
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

  defp gen_layout_templates(config) do
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

  defp gen_generators(config) do
    binding = Kernel.binding() ++ [base: config.base, target_name: config.target_name,
      target_module: config.target_module, web_namespace: config.web_namespace]
    theme = config.theme
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

  def gen_images(config) do
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

  def gen_vendor(config) do
    unless config.dry_run do
      source_path = Path.join([@source_path_relative, config.target_name, "assets"])
      target_path = Path.join([config.vendor_parent])

      File.mkdir_p! target_path
      copy_from paths(), source_path, target_path, [target_name: config.target_name],
        theme_asset_files(config.target_name), config
    end
    config
  end

  defp theme_asset_files(theme) do
    @vendor_files[theme]
    |> Enum.map(fn {path, files} ->
      Enum.map(files, fn file ->
        fpath = Path.join(path, file)
        {:eex, fpath, fpath}
      end)
    end)
    |> List.flatten
    # |> IO.inspect(label: "theme #{inspect theme} files")
  end

  # defp verify_brunch(%{brunch: true} = config) do

  # end

  # defp verify_brunch(config) do
  #   config
  # end

  # defp gen_brunch(config) do

  #   config
  # end
  # def do_assets(%Config{assets: true, brunch: true} = config) do
  #   base_path = Path.join(~w(priv static))

  #   File.mkdir_p Path.join ~w{web static vendor}
  #   File.mkdir_p Path.join ~w{web static assets fonts}
  #   File.mkdir_p Path.join ~w{web static assets images ex_admin datepicker}

  #   status_msg("creating", "css files")
  #   ~w(admin_lte2.css admin_lte2.css.map active_admin.css.css active_admin.css.css.map)
  #   |> Enum.each(&(copy_vendor base_path, "css", &1))

  #   status_msg("creating", "js files")
  #   ~w(jquery.min.js admin_lte2.js jquery.min.js.map admin_lte2.js.map)
  #   ++ ~w(ex_admin_common.js ex_admin_common.js.map)
  #   |> Enum.each(&(copy_vendor base_path, "js", &1))

  #   copy_vendor_r(base_path, "fonts")
  #   copy_vendor_r(base_path, "images")

  #   case File.read "brunch-config.js" do
  #     {:ok, file} ->
  #       File.write! "brunch-config.js", file <> brunch_instructions()
  #     error ->
  #       Mix.raise """
  #       Could not open brunch-config.js file. #{inspect error}
  #       """
  #   end
  #   config
  # end

  defp print_instructions(config) do
    Mix.shell.info """

    """
    config
  end

  # def gen_brunch_boilerplate(config) do

  # end

  # def brunch_instructions(mode) do
  #   """

  #   // To add the Talon generated assets to your brunch build, do the following:
  #   //
  #   // Replace
  #   //
  #   //     javascripts: {
  #   //       joinTo: "js/app.js"
  #   //     },
  #   //
  #   // With
  #   //
  #   //     javascripts: {
  #   //       joinTo: {
  #   //         "js/app.js": /^(#{brunch_snippets(mode, :root_match)}js)|(node_modules)/,
  #   //         'js/talon/admin_lte/jquery-2.2.3.min.js': 'web/static/vendor/talon/admin-lte/plugins/jQuery/jquery-2.2.3.min.js',
  #   //         'js/talon/admin_lte/bootstrap.min.js': 'web/static/vendor/talon/admin-lte/bootstrap/js/bootstrap.min.js',
  #   //         'js/talon/admin_lte/app.min.js': 'web/static/vendor/talon/admin-lte/dist/js/app.min.js'
  #   //       }
  #   //     },
  #   //
  #   // Replace
  #   //
  #   //     stylesheets: {
  #   //       joinTo: "css/app.css"
  #   //     },
  #   //
  #   // With
  #   //
  #   //     stylesheets: {
  #   //       joinTo: {
  #   //         "css/app.css": /^(#{brunch_snippets(mode, :root_match)}css)/,
  #   //         "css/talon/admin_lte/talon.css": [
  #   //           "#{brunch_snippets(mode, :root_path)}css/talon/admin-lte/talon.css",
  #   //           "#{brunch_snippets(mode, :root_path)}vendor/talon/admin-lte/dist/css/skins/all-skins.css",
  #   //           "#{brunch_snippets(mode, :root_path)}vendor/talon/admin-lte/bootstrap/css/bootstrap.min.css",
  #   //           "#{brunch_snippets(mode, :root_path)}vendor/talon/admin-lte/dist/css/AdminLTE.min.css"
  #   //         ]
  #   //       }
  #   //     },
  #   //
  #   """
  # end

  # defp brunch_snippets(:phx, :root_match), do: ""
  # defp brunch_snippets(_, :root_match), do: "web\\/static\\/"
  # defp brunch_snippets(:phx, :root_path), do: ""
  # defp brunch_snippets(_, :root_path), do: "web/static/"

  defp do_config({bin_opts, opts, parsed} = _args) do
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
        bin_opts[:phx] -> :phx
        bin_opts[:phoenix] -> :phoenix
        true -> detect_project_structure()
      end

    view_opts = view_opts(theme, proj_struct)

    %{
      theme: theme,
      target_name: target_name,
      target_module: theme_module_name(theme),
      verbose: bin_opts[:verbose],
      dry_run: bin_opts[:dry_run],
      project_structure: proj_struct,
      web_namespace: web_namespace(proj_struct),
      web_path: opts[:web_path] || web_path(verify: true),
      view_opts: view_opts,
      binding: binding,
      boilerplate: bin_opts[:boilerplate] || Application.get_env(:talon, :boilerplate, true),
      base: bin_opts[:module] || binding[:base],
    }
  end

  defp web_namespace(:phx), do: "Web."
  defp web_namespace(_), do: ""

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

  # defp lib_path do
  #   Path.join("lib", to_string(Mix.Phoenix.otp_app()))
  # end

  defp paths do
    [".", :talon]
  end
end
