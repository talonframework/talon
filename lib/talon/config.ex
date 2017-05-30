defmodule Talon.Config do
  @moduledoc """
  Convenience wrappers around fetching Talon Configuration
  """

  @doc false
  defmacro __using__(_) do
    quote do
      alias Talon.Config
    end
  end

  @doc """
  Get the configuration for a given context
  """
  defmacro get_env(context) do
    quote do
      Application.get_env(:talon, unquote(context), [])
    end
  end

  @doc """
  Get the currently configured theme
  """
  defmacro theme(context) do
    quote do
      Keyword.get(Talon.Config.get_env(unquote(context)), :theme)
    end
  end

  defmacro contexts do
    quote do
      Application.get_env(:talon, :contexts)
    end
  end

  defmacro resources(context) do
    quote do
      Keyword.get(Talon.Config.get_env(unquote(context)), :resources, [])
    end
  end

end
