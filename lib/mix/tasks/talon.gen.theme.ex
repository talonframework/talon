defmodule Mix.Tasks.Talon.Gen.Theme do
  @moduledoc """
  Create a new Talon theme.

      mix talon.gen.theme theme target_name

  Copies `theme` to a new `theme_name`. Creates the following files:

  * web/views/talon/target_name path
  * web/templates/talon/target_name/generators path
    * edit.html.eex
    * form.html.eex
    * index.html.eex
    * new.html.eex
    * show.html.eex
  * assets_path/vendor

  ## Options

  * --dry-run -- print what will be done, but don't create any files
  * --verbose -- Print extra information
  """
  use Mix.Task

  import Mix.Talon
  # import Mix.Generator

  # list all supported boolean options
  @boolean_options ~w(all_themes verbose boilerplate dry_run no_assets no_brunch)a

  # complete list of supported options
  @switches [
    theme: :string
  ] ++ Enum.map(@boolean_options, &({&1, :boolean}))

  @default_theme "admin_lte"
  @source_path Path.join(~w(priv templates talon.gen.theme))

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
    |> gen_brunch
    |> gen_components
    |> print_instructions
  end

  defp gen_components(config) do
    opts = if config[:verbose], do: ["--verbose"], else: []
    opts = if config[:dry_run], do: ["--dry-run" | opts], else: opts

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
      target_module: config.target_module]
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

  defp gen_images(config) do
    unless config.dry_run do
      source_path = Path.join([@source_path, "assets", "images"])
      target_path = Path.join([config.images_path, "talon", config.target_name])

      files =
        source_path
        |> Path.join("*")
        |> Path.wildcard
        |> Enum.map(&Path.basename/1)

      File.mkdir_p! target_path
      copy_from paths(), source_path, target_path, [], files, config
    end
    config
  end

  defp gen_vendor(config) do
    unless config.dry_run do
      source_path = Path.join([@source_path, config.target_name, "assets"]) |> IO.inspect(label: "source_path")
      target_path = Path.join([config.vendor_parent])

      File.mkdir_p! target_path
      copy_from paths(), source_path, target_path, [],
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

  defp gen_brunch(config) do

    config
  end

  defp print_instructions(config) do
    Mix.shell.info """

    """
    config
  end

  defp do_config({bin_opts, _opts, parsed} = _args) do
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
    proj_struct = detect_project_structure()
    view_opts = view_opts(theme, proj_struct)

    %{
      theme: theme,
      target_name: target_name,
      target_module: theme_module_name(theme),
      verbose: bin_opts[:verbose],
      dry_run: bin_opts[:dry_run],
      project_structure: proj_struct,
      web_namespace: web_namespace(proj_struct),
      web_path: web_path(verify: true),
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
