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
    |> gen_layout_view
    |> gen_layout_templates
    |> gen_generators
    |> gen_assets
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
    binding = Kernel.binding() ++ [base: config.base, target_name: config.target_name, target_module: config.target_module]
    theme = config.theme
    view_path = Path.join([web_path(), "views", "talon", config.target_name])
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
    binding = Kernel.binding()
    theme = config.theme
    template_path = Path.join([web_path(), "templates", "talon", config.theme, "layout"])
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
    template_path = Path.join([web_path(), "templates", "talon", config.theme, "generators"])
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

  defp gen_assets(config) do

    config
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

    %{
      theme: theme,
      target_name: target_name,
      target_module: Inflex.camelize(target_name),
      verbose: bin_opts[:verbose],
      dry_run: bin_opts[:dry_run],
      # package_path: get_package_path(),
      binding: binding,
      boilerplate: bin_opts[:boilerplate] || Application.get_env(:talon, :boilerplate, true),
      base: bin_opts[:module] || binding[:base],
    }
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

  # defp lib_path do
  #   Path.join("lib", to_string(Mix.Phoenix.otp_app()))
  # end

  defp web_path do
    path1 = Path.join ["lib", to_string(Mix.Phoenix.otp_app()), "web"]
    path2 = "web"
    cond do
      File.exists? path1 -> path1
      File.exists? path2 -> path2
      true ->
        raise "Could not find web path '#{path1}'. Please use --web-path option to specify"
    end
  end

  defp paths do
    [".", :talon]
  end
end
