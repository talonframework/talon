defmodule Mix.Talon do
  @moduledoc """
  Mix helpers.
  """

  @doc """
  Get the configured themes.

  Defaults to the "admin_lte" default them if not configured.
  """
  @spec themes() :: String.t
  def themes do
    Application.get_env :talon, :themes, ["admin_lte"]
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

  defp to_app_source(path, source_dir) when is_binary(path),
    do: Path.join(path, source_dir)
  defp to_app_source(app, source_dir) when is_atom(app),
    do: Application.app_dir(app, source_dir)
end


