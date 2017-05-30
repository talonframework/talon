defmodule Mix.Talon do
  @moduledoc """
  Mix helpers.
  """

  @doc """
  Get the configured themes.

  Defaults to the "admin_lte" default them if not configured.
  """

  require Talon.Config, as: Config

  @spec themes() :: String.t
  def themes do
    Config.contexts
    |> Enum.map(&Config.theme/1)
    |> Enum.uniq
  end

  @doc """
  Check the provided options.

  Raises error if an invalid option is provided.
  """
  @spec verify_args!([String.t] | [], [String.t] | []) :: String.t | nil
  def verify_args!(parsed, unknown) do
    unless parsed == [] do
      opts = Enum.join parsed, ", "
      Mix.raise """
      Invalid argument(s) #{opts}
      """
    end
    unless unknown == [] do
      opts =
        unknown
        |> Enum.map(&(elem(&1,0)))
        |> Enum.join(", ")
      Mix.raise """
      Invalid argument(s) #{opts}
      """
    end
  end

  @doc false
  @spec log(Map.t, String.t, Keyword.t) :: Map.t
  def log(config, message, opts \\ [])
  def log(%{verbose: true} = config, message, opts) do
    label =
      case opts[:label] do
        nil -> ""
        label -> "#{label}: "
      end
    Mix.shell.info label <> message
    config
  end
  def log(config, _message, _opts) do
    config
  end

  @doc """
  Find the package path.

  Resoves the package path.
  """
  # This is a bit of a hack, but it works. There is a better
  @spec get_package_path() :: String.t
  def get_package_path do
    __ENV__.file
    |> Path.dirname
    |> String.split("/lib/mix")
    |> hd
  end

  @doc """
  Get the base module name
  """
  @spec get_module() :: String.t
  def get_module do
    Mix.Project.get
    |> Module.split
    |> Enum.reverse
    |> Enum.at(1)
  end

  @doc """
  Copies files from source dir to target dir according to the given map.
  Files are evaluated against EEx according to the given binding.
  """
  @spec copy_from(List.t, String.t, String.t, List.t, [tuple], Map.t) :: any
  def copy_from(apps, source_dir, target_dir, binding, mapping, config) when is_list(mapping) do
    roots = Enum.map(apps, &to_app_source(&1, source_dir))

    create_opts = if config[:confirm], do: [], else: [force: true]

    for {format, source_file_path, target_file_path} <- mapping do
      source =
        Enum.find_value(roots, fn root ->
          source = Path.join(root, source_file_path)
          if File.exists?(source), do: source
        end) || raise("could not find #{source_file_path} in any of the sources")

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

  # def source_path(apps, source_dir) do
  #   roots = Enum.map(apps, &to_app_source(&1, source_dir))
  #   # source =
  # end

  defp to_app_source(path, source_dir) when is_binary(path),
    do: Path.join(path, source_dir)
  defp to_app_source(app, source_dir) when is_atom(app),
    do: Application.app_dir(app, source_dir)

  @spec detect_project_structure() :: :phx | :phoenix | :unknown
  def detect_project_structure do
    phx_dir = otp_app_path()
    cond do
      File.exists?("web") -> :phoenix
      Path.join(["lib", phx_dir, "web"]) |> File.exists? -> :phx
      true -> :unknown
    end
  end

  @spec otp_app_path() :: String.t
  def otp_app_path do
    to_string(Mix.Phoenix.otp_app())
  end

  @spec prompt_project_structure(Keyword.t) :: :phx | :phoenix | :unknown
  def prompt_project_structure(binding) do
    Mix.shell.info [
      "Cannot automatically detect the project structure!\n",
      "1. Use phx 1.3 structure (lib/#{binding.base}/web)\n",
      "2. Use phoenix structure (web)\n",
      "3. Abort\n",
    ]

    case Mix.shell.prompt("Please make a selection") do
      "1" <> _ ->
        Mix.shell.info("Using phx structure")
        :phx
      "2" <> _ ->
        Mix.shell.info("Using phoenix structure")
        :phoenix
      "3" <> _ ->
        Mix.raise("User aborted installation!")
      _ ->
        Mix.shell.info "Sorry, that's not a valid selection"
        prompt_project_structure(binding)
    end
  end

  @spec assets_paths(Map.t) :: Map.t
  def assets_paths(config) do
    proj_struct = config.project_structure
    config
    |> Map.put(:brunch_path, brunch_path(proj_struct))
    |> Map.put(:images_path, images_path(proj_struct))
    |> Map.put(:vendor_parent, vendor_parent(proj_struct))
  end

  defp images_path(:phx), do: Path.join(~w(assets static images))
  defp images_path(_), do: Path.join(~w(web static assets images))

  defp vendor_parent(:phx), do: "assets"
  defp vendor_parent(_), do: Path.join(~w(web static))

  @doc """
  Return the current web path based on project structure

  Checks if the project uses phx 1.3 project structure or not. Then
  verifies that the path exists.

  ## Options

  * verify (false) -- Verify if the path exists
  """
  @spec web_path(Keyword.t) :: String.t
  def web_path(opts \\ []) do
    path =
      case detect_project_structure() do
        :phx -> Path.join ["lib", otp_app_path(), "web"]
        _    -> "web"
      end

    if opts[:verify] do
      unless File.exists?(path), do: Mix.raise("Could not find web path")
    end
    path
  end

  @spec theme_module(String.t) :: Module.t
  def theme_module(theme) do
    theme |> theme_module_name |> Module.concat(nil)
  end

  @spec theme_module_name(String.t) :: String.t
  def theme_module_name(theme) do
    Inflex.camelize(theme)
  end

  @doc """
  Return the theme namespaced options for `use Talon.Web, :view`

  ## Examples

      iex> Talon.Mix.view_opts("admin_lte", :phx)
      ~s(, theme: "admin_lte", module: AdminLte.Web)
      iex> Talon.Mix.view_opts("admin_lte", :phoenix)
      ~s(, theme: "admin_lte", module: AdminLte)
  """
  @spec view_opts(String.t, atom) :: String.t
  def view_opts(theme, proj_struct) do
    name = theme_module_name(theme)
    module =
      if proj_struct == :phx, do: Module.concat(name, Web) |> inspect, else: name
    ~s(, theme: "#{theme}", module: #{module})
  end

  @doc """
  Return the Web module name space for phx-1.3 projects

  ## Examples

      iex> Talon.Mix.web_namespace(:phx)
      "Web."
      iex> Talon.Mix.web_namespace(:phx)
  """
  @spec web_namespace(:phx | :phoneix) :: String.t
  def web_namespace(:phx), do: "Web."
  def web_namespace(:phoenix), do: ""

  @spec brunch_path(:phx | :phoenix) :: String.t
  def brunch_path(:phx), do: Path.join(~w(assets brunch-config.js))
  def brunch_path(:phoenix), do: "brunch-config.js"

  def common_absolute_path(app) do
    to_app_source app, Path.join(["priv", "templates", "common"])
  end
end


