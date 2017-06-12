defmodule Mix.Tasks.Talon.Gen.Resource do
  @moduledoc """
  Generate the Talon Resource files

  Creates the resource files needed to manage a schema with Talon.

      mix talon.gen.resource User
      mix talon.gen.resource FrontEnd Blogs.Blog

  Two arguments can be passed to the task. The first is an optional
  Talon concern. The second argument is a schema to be managed with
  Talon.

  If the concern argument is omitted, the fist concern from the
  `concerns` configuration list will be used.

  Creates the following files:

  * web/layout/talon/admin-lte/user_view.ex
  * lib/my_app/talon/user.ex

  ## Options

  * --theme=custom_theme -- create the layout file for a custom theme
  * --all-themes -- create the layout for all configured themes
  * --no-boilerplate -- don't include the boilerplate comments
  * --dry-run -- print what will be done, but don't create any files
  """
  use Mix.Task

  import Mix.Talon

  @default_theme "admin-lte"

  # list all supported boolean options
  @boolean_options ~w(all_themes verbose boilerplate dry_run)a

  # complete list of supported options
  @switches [
    theme: :string, concern: :string, module: :string,
    root_path: :string, path_prefix: :string
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
    |> do_config(args)
    |> do_run
  end

  defp do_run(config) do
    log config, inspect(config), label: "config"
    config
    |> create_resource_file
    |> create_view
    |> print_instructions
  end

  def create_resource_file(config) do
    binding = config.binding ++ [base: config[:base], boilerplate: config.boilerplate,
      resource: config.resource, scoped_resource: config.scoped_resource, module: config.module,
      concern: config.concern, app: config.app]
    name = Inflex.underscore config.resource
    target_path = Path.join([config.root_path, config.path_prefix, config.concern_path])
    unless config.dry_run do
      copy_from paths(),
        "priv/templates/talon.gen.resource", target_path, binding, [
          {:eex, "resource.ex", "#{name}.ex"}
        ], config
    end
    config
  end

  def create_view(config) do
    name = Inflex.underscore config.resource
    unless config.dry_run do
      # Enum.each config.themes, fn theme ->
        theme = config.target_name
        binding = config.binding ++ [base: config[:base], resource: config.resource,
          theme_module: theme_module_name(theme), theme_name: theme, view_opts: config.view_opts,
          web_namespace: config.web_namespace, concern: config.concern]
        target_path = Path.join([config.root_path, "views", config.path_prefix,
            config.concern_path, theme])
        copy_from paths(),
          "priv/templates/talon.gen.resource", target_path, binding, [
            {:eex, "view.ex", "#{name}_view.ex"}
          ], config
      # end
    end
    config
  end

  def print_instructions(config) do
    Mix.shell.info """
      Remember to update your config/talon.exs file with the resource module
        config :#{config.app}, #{config.base}.#{config.concern},
          :resources, [
            ...
            #{config.base}.#{inspect config.module}
          ]
      """
    config
  end

  def normalize_module(module, _binding) do
    module
  end

  defp do_config({bin_opts, opts, parsed}, raw_args) do
    {concern, theme_name} = process_concern_theme(opts)

    target_name = Keyword.get(opts, :target_theme, theme_name)
    target_module = Inflex.camelize(target_name)


    binding =
      Mix.Project.config
      |> Keyword.fetch!(:app)
      |> Atom.to_string
      |> Mix.Phoenix.inflect

    base = opts[:module] || binding[:base]

    scoped_resource =
      case parsed do
        [resource] ->
          normalize_module(resource, binding)
        other ->
          Mix.raise "Invalid arguments #{inspect other}"
      end

    proj_struct = detect_project_structure()

    resource =
      with :phx <- proj_struct,
           true <- String.contains?(scoped_resource, "."),
           [_scope, resource | tail]  <- String.split(scoped_resource, ".") do
        Enum.join([resource | tail], ".")
      else
        _ -> scoped_resource
      end

    view_opts =
      %{target_name: target_name, base: base, concern: concern}
      |> view_opts(proj_struct)

    app = opts[:app_name] || Mix.Project.config |> Keyword.fetch!(:app)
    app_path_name = app |> to_string |> Inflex.underscore
    root_path = opts[:root_path] || Path.join(["lib", app_path_name, default_root_path()])
    # concerns = Config.concerns() || [concern]
    # unless concerns, do: Mix.raise("You must add :talon, :concerns to your config/talon.exs file")

    # IO.inspect {opts[:concern], hd(concerns)}, label: "...."
    # concern = Module.concat(opts[:concern] || hd(concerns), nil)

    # TODO: not sure if this is right
    module = opts[:module] || Module.concat(concern, scoped_resource)

    %{
      # themes: get_themes(args),
      app: app,
      raw_args: raw_args,
      theme: opts[:theme] || @default_theme,
      concern: concern,
      concern_path: concern_path(concern),
      module: module,
      verbose: bin_opts[:verbose],
      resource: resource,
      scoped_resource: scoped_resource,
      root_path: root_path,
      path_prefix: opts[:path_prefix] || default_path_prefix(),
      dry_run: bin_opts[:dry_run],
      target_name: target_name,
      target_module: target_module,
      view_opts: view_opts,
      binding: binding,
      lib_path: lib_path(),
      web_namespace: web_namespace(proj_struct),
      project_structure: proj_struct,
      boilerplate: bin_opts[:boilerplate] || Application.get_env(:talon, :boilerplate, true),
      base: base,
    }
    # |> IO.inspect(label: "contfig")
  end

  # defp get_themes({opts, bin_opts, _parsed}) do
  #   cond do
  #     bin_opts[:all_themes] -> all_themes()
  #     opts[:theme] -> [opts[:theme]]
  #     all = all_themes() -> Enum.take(all, 1)
  #   end
  # end

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

  defp lib_path do
    Path.join("lib", to_string(Mix.Phoenix.otp_app()))
  end

  defp paths do
    [".", :talon]
  end
end
