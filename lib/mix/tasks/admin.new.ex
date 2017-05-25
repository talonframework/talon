defmodule Mix.Tasks.Admin.New do
  @moduledoc """
  Add ExAdmin to an existing Phoenix Project.

      mix admin.install

  Creates the following files:

  * web/views/admin/admin_lte path
  * web/controllers/admin/admin_resource_controller.ex
  * web/templates/admin/admin_lte/generators path
    * edit.html.eex
    * form.html.eex
    * index.html.eex
    * new.html.eex
    * show.html.eex
  * lib/my_app/admin/admin.ex
  * config/ex_admin.exs
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

  import Mix.ExAdmin
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
    |> verify_project!
    |> gen_config
    |> gen_admin_context
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
    fname = "ex_admin.exs"
    binding = Kernel.binding() ++ [base: config.base, theme: config.theme]
    unless config.dry_run do
      copy_from paths(),
        "priv/templates/admin.new/config", "config", binding, [
          {:eex, fname, fname},
        ], config
    end

    path = "config/config.exs"

    contents = File.read!(path)
    unless String.contains? contents, fname do
      File.write path, contents <> "\n" <> ~s(import_config "#{fname}"\n)
    end
    config
  end

  def gen_admin_context(config) do
    fname = "admin.ex"
    binding = Kernel.binding() ++ [base: config.base, app: config.app, boilerplate: config.boilerplate]
    target_path = "lib/#{config.app}/admin"
    unless config.dry_run do
      File.mkdir_p! target_path
      copy_from paths(),
        "priv/templates/admin.new/lib", target_path, binding, [
          {:eex, "admin_context.ex", fname},
        ], config
    end
   config
  end

  def gen_controller(config) do
    fname = "admin_resource_controller.ex"
    binding = Kernel.binding() ++ [base: config.base, boilerplate: config[:boilerplate]]
    target_path = Path.join([web_path(), "controllers", "admin"])
    unless config.dry_run do
      File.mkdir_p! target_path
      copy_from paths(),
        "priv/templates/admin.new/web/controllers", target_path, binding, [
          {:eex, fname, fname},
        ], config
    end
   config
  end

  def gen_web(config) do
    fname = "admin_web.ex"
    binding = Kernel.binding() ++ [base: config.base]
    target_path = web_path()
    unless config.dry_run do
      File.mkdir_p! target_path
      copy_from paths(),
        "priv/templates/admin.new/web", target_path, binding, [
          {:eex, fname, fname},
        ], config
    end
   config
  end

  def gen_messages(config) do
    fname = "messages.ex"
    binding = Kernel.binding() ++ [base: config.base]
    target_path = web_path()
    unless config.dry_run do
      File.mkdir_p! target_path
      copy_from paths(),
        "priv/templates/admin.new/web", target_path, binding, [
          {:eex, fname, fname},
        ], config
    end
   config
  end

  def gen_theme(config) do
    opts = if config[:verbose], do: ["--verbose"], else: []
    opts = if config[:dry_run], do: ["--dry-run" | opts], else: opts

    Mix.Tasks.Admin.Gen.Theme.run([@default_theme, @default_theme] ++ opts)
    config
  end

  def print_instructions(config) do
    Mix.shell.info """

      """
    config
  end

  defp do_config({bin_opts, opts, _parsed} = args) do
    binding =
      Mix.Project.config
      |> Keyword.fetch!(:app)
      |> Atom.to_string
      |> Mix.Phoenix.inflect

    %{
      themes: get_themes(args),
      theme: opts[:theme] || @default_theme,
      verbose: bin_opts[:verbose],
      dry_run: bin_opts[:dry_run],
      package_path: get_package_path(),
      app: Mix.Project.config |> Keyword.fetch!(:app),
      binding: binding,
      boilerplate: bin_opts[:boilerplate] || Application.get_env(:ex_admin, :boilerplate, true),
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
    Application.get_env :ex_admin, :themes, [@default_theme]
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
    [".", :ex_admin]
  end
end
