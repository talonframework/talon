defmodule Mix.Tasks.Talon.Gen.Components do
  @moduledoc """
  Create the installed components.

      mix talon.gen.components theme

  This is a supporting mix task that is used by the talon.gen.theme task.
  It is the foundation for an optional component installer. However, we
  don't have any optional components at this time.

  ## Options

  * --dry-run -- print what will be done, but don't create any files
  * --verbose -- Print extra information
  """
  use Mix.Task

  import Mix.Talon

  # list all supported boolean options
  @boolean_options ~w(verbose dry_run)a

  # complete list of supported options
  @switches [
  ] ++ Enum.map(@boolean_options, &({&1, :boolean}))

  @component_path "priv/templates/talon.gen.components/components/*"


  @doc """
  The entry point of the mix task.
  """
  @spec run(List.t) :: any
  def run(args) do
    Mix.shell.info "Running talon.gen.components"
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
    |> get_components
    |> gen_components
  end

  defp get_components(config) do
    components =
      :talon
      |> Application.app_dir(@component_path)
      |> Path.wildcard
      |> Enum.filter_map(&File.dir?/1, & {Path.basename(&1), &1})

    {config, components}
  end

  defp gen_components({config, components}) do
    components
    |> Enum.reduce(config, &gen_component(&2, &1))
  end

  defp gen_component(config, component) do
    config
    |> gen_component_views(component)
    |> gen_component_templates(component)
  end

  defp gen_component_views(config, {_component, component_path} = comp_info) do
    source_path = Path.join([component_path, "views"])
    target_path = Path.join([web_path(), "views", "talon", config.theme_name, "components"])

    gen_files(config, comp_info, source_path, target_path)
  end

  defp gen_component_templates(config, {component, component_path} = comp_info) do
    source_path = Path.join([component_path, "templates"])
    target_path = Path.join([web_path(), "templates", "talon", config.theme_name, "components", component])

    gen_files(config, comp_info, source_path, target_path)
  end

  defp gen_files(config, {_, component_path}, source_path, target_path) do
    file_names =
      source_path
      |> Path.join("*")
      |> Path.wildcard
      |> Enum.map(&Path.basename/1)

    binding = Kernel.binding() ++ [base: config.base, theme_name: config.theme_name, theme_module: config.theme_module]

    infos =
      file_names
      |> Enum.map(& "copy #{source_path}/#{&1} to #{target_path}/#{&1}")

    if config.dry_run do
      Enum.each infos, &(Mix.shell.info("# " <> &1))
    else
      if config.verbose, do: Enum.each(infos, &Mix.shell.info/1)

      File.mkdir_p! target_path

      copy_from source_path, target_path, binding,
        Enum.map(file_names, & {:eex, &1, &1}), config
    end
    config
  end

  defp do_config({bin_opts, _opts, parsed} = _args) do
    themes = get_available_themes()

    theme_name =
      case parsed do
        [theme] ->
          unless theme in themes,
            do: Mix.raise("Invalid theme name. Choices are #{inspect themes}")
          theme
        other ->
          Mix.raise "Invalid arguments #{inspect other}"
      end

    theme_module = Inflex.camelize(theme_name)

    binding =
      Mix.Project.config
      |> Keyword.fetch!(:app)
      |> Atom.to_string
      |> Mix.Phoenix.inflect

    %{
      theme_name: theme_name,
      theme_module: theme_module,
      verbose: bin_opts[:verbose],
      dry_run: bin_opts[:dry_run],
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

  defp parse_options([], parsed) do
    {[], [], parsed}
  end
  defp parse_options(opts, parsed) do
    bin_opts = Enum.filter(opts, fn {k,_v} -> k in @boolean_options end)
    {bin_opts, opts -- bin_opts, parsed}
  end

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

  defp copy_from(source_dir, target_dir, binding, mapping, config) when is_list(mapping) do

    create_opts = if config[:confirm], do: [], else: [force: true]

    for {format, source_file_path, target_file_path} <- mapping do
      source = Path.join(source_dir, source_file_path)
      unless File.exists?(source) do
        raise("could not find #{source_file_path} in any of the sources")
      end

      target = Path.join(target_dir, target_file_path)
      contents =
        case format do
          :text -> File.read!(source)
          :eex  -> EEx.eval_file(source, binding)
        end
      if File.exists? target do
        fname = Path.split(target) |> List.last
        if Mix.shell.yes?("File #{fname} exists. Replace it?"), do: true, else: false
      else
        true
      end
      |> if do
        Mix.Generator.create_file(target, contents, create_opts)
      end
    end
  end
end
