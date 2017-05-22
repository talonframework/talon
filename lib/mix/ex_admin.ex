defmodule Mix.ExAdmin do
  @moduledoc """
  Mix helpers.
  """

  @doc """
  Get the configured themes.

  Defaults to the "admin_lte" default them if not configured.
  """
  @spec themes() :: String.t
  def themes do
    Application.get_env :ex_admin, :themes, ["admin_lte"]
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
end


