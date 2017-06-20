defmodule Mix.Tasks.Talon.Gen.Concern do
  @moduledoc """
  Create a concern.

      mix talon.gen.concern Front

  ## Options

  * --dry-run -- print what will be done, but don't create any files
  * --verbose -- Print extra information
  """
  use Mix.Task

  import Mix.Talon
  require Talon.Config, as: Config

  # list all supported boolean options
  @boolean_options ~w(verbose dry_run)a

  # complete list of supported options
  @switches [
    root_path: :string, proj_struct: :string, path_prefix: :string,
    target_theme: :string, theme_name: :string, theme: :string
  ] ++ Enum.map(@boolean_options, &({&1, :boolean}))


  @doc """
  The entry point of the mix task.
  """
  @spec run(List.t) :: any
  def run(args) do
    Mix.shell.info "Running talon.gen.concern"
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
    |> gen_talon_concern
    |> gen_config
    |> gen_controller
    |> print_route_instructions
  end

  def gen_talon_concern(config) do
    concern_path = Inflex.underscore(config.concern)
    fname = concern_path <> ".ex"
    binding = Kernel.binding() ++ [base: config.base, app: config.app,
      boilerplate: config.boilerplate, concern: to_s(config.concern)]
    target_path = Path.join config.root_path, concern_path
    unless config.dry_run do
      # File.mkdir_p! target_path
      copy_from paths(),
        "priv/templates/talon.new/web", target_path, binding, [
          {:eex, "talon_concern.ex", fname},
        ], config
    end
   config
  end

  def gen_config(config) do
    concern_config_path = Application.app_dir(:talon,
      "priv/templates/talon.new/config/concern_config.exs")
    binding = Kernel.binding() ++ [
      config: config, theme: config.theme_name,
    ]
    unless config.dry_run do
      path = "config/talon.exs"
      concern_contents = EEx.eval_file(concern_config_path, binding)
      contents = File.read!(path)
      File.write path, contents <> concern_contents
    end
    config
  end

  def gen_controller(config) do
    fname = "resource_controller.ex"
    target_fname = Inflex.underscore(config.concern) <> "_" <> fname
    web_module = web_module config.web_namespace
    layout = Module.concat([config.base, config.concern, config.theme_module,
      web_module, LayoutView])
    layout = ~s/{#{inspect layout}, "app.html"}/
    binding = Kernel.binding() ++ [base: config.base, concern: config.concern,
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

  defp print_route_instructions(config) do
    namespace =
      if config.project_structure == :phx do
        "#{config.base}.Web"
      else
        config.base
      end
    full_concern = Module.concat config.base, config.concern

    route_scope = Inflex.underscore(config.concern)

    Mix.shell.info """

    Add the concern routes to your web/router.ex:

      # your concern routes
      scope "/#{route_scope}", #{namespace} do
        pipe_through :browser
        talon_routes(#{to_s full_concern})
      end
    """
    config
  end

  defp do_config({bin_opts, opts, parsed} = _args) do
    concern =
      case parsed do
        [concern] -> concern
        _ ->
          Mix.raise("Expected concern argument")
      end

    binding =
      Mix.Project.config
      |> Keyword.fetch!(:app)
      |> Atom.to_string
      |> Mix.Phoenix.inflect

    base = opts[:module] || binding[:base]

    proj_struct = to_atom(opts[:proj_struct] || detect_project_structure())

    app = opts[:app_name] || Mix.Project.config |> Keyword.fetch!(:app)
    app_path_name = app |> to_string |> Inflex.underscore
    root_path = opts[:root_path] || Path.join(["lib", app_path_name, default_root_path()])

    theme_name = opts[:target_theme] || opts[:theme_name] || opts[:theme] || default_theme()
    theme_module = Inflex.camelize theme_name

    %{
      verbose: bin_opts[:verbose],
      dry_run: bin_opts[:dry_run],
      binding: binding,
      root_path: root_path,
      path_prefix: opts[:path_prefix] || default_path_prefix(),
      theme_name: theme_name,
      theme_module: theme_module,
      project_structure: proj_struct,
      web_namespace: web_namespace(proj_struct),
      concern: concern,
      concern_path: concern_path(concern),
      boilerplate: bin_opts[:boilerplate] || Config.boilerplate() || true,
      base: base,
      app: app
    }
  end

  defp to_atom(atom) when is_atom(atom), do: atom
  defp to_atom(string), do: String.to_atom(string)

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
