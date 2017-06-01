defmodule Talon do

  @doc """
  Return the app's base module.

  ## Examples

      iex> Talon.app_module(TestTalon.Talon)
      TestTalon
  """
  @spec app_module(atom) :: atom
  def app_module(talon) do
    talon.base()
  end

  @spec web_namespace() :: Module.t | nil
  def web_namespace do
    Application.get_env(:talon, :web_namespace)
  end

  @spec web_path() :: String.t
  def web_path do
    case Application.get_env(:talon, :web_namespace) do
      nil -> "web"
      _ ->
        mod = Application.get_env(:talon, :module)
        Path.join(["lib", Inflex.underscore(mod), "web"])
    end
  end
end
