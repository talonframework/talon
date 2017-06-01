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

  defmacro get_app do
    app = Mix.Project.config[:app]
    quote do
      unquote(app)
    end
  end

  @doc """
  Get the configuration for a given context
  """
  defmacro get_all_env(context) do
    quote do
      Talon.Config.get_app()
      |> Application.get_env(unquote(context), [])
    end
  end

  defmacro get_env(context, key, default \\ nil) do
    quote do
      Keyword.get(Talon.Config.get_env(unquote(context), unquote(key), unquote(default)))
    end
  end

  defmacro get_env(field) do
    quote do
      Talon.Config.get_app() |> Application.get_env(unquote(field))
    end
  end

  defmacro contexts do
    quote do
      Talon.Config.get_env(:contexts)
    end
  end

  defmacro module do
    quote do
      Talon.Conifg.get_env(:module)
    end
  end

  @doc """
  Get the currently configured theme
  """
  defmacro theme(context) do
    quote do
      Talon.Config.get_env(unquote(context), :theme)
    end
  end

  defmacro resources(context) do
    quote do
      Talon.Config.get_env(unquote(context), :resources)
    end
  end

  defmacro endpoint(context) do
    quote do
      Talon.Config.get_env(unquote(context), :endpoint)
    end
  end

  defmacro router(context) do
    quote do
      Talon.Config.get_env(unquote(context), :router)
    end
  end

end
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
