defmodule Talon.Config do
  @moduledoc """
  Convenience wrappers around fetching Talon Configuration


  """

  @overridable_config [
    theme: nil, endpoint: nil, router: nil, repo: nil, schema_adapter: nil,
    paginate: true, messages_backend: nil
  ]
  # @overridable_keys Keyword.keys(@overridable_config)

  @top_level_config [
    concerns: nil, module: nil, themes: [],
    compiler_opts: [], boilerplate: true,
    web_namespace: nil
  ] ++ @overridable_config

  @top_level_keys Keyword.keys(@top_level_config)

  @doc false
  defmacro __using__(_) do
    quote do
      alias Talon.Config
    end
  end

  defmacro get_app do
    app =
      if Mix.Project.umbrella? do
        # FIXME: hack to work with umbrella apps, but only one Talon app allow this way
        Application.get_env(:talon, :talon_app)
      else
        Mix.Project.config[:app]
      end
    quote do
      unquote(app)
      :admin
    end
  end

  @doc """
  Get the configuration for a given concern
  """
  defmacro get_all_env(concern) do
    quote do
      Talon.Config.get_app()
      |> Application.get_env(unquote(concern), [])
    end
  end

  defmacro get_env(concern, key, default \\ nil)
  defmacro get_env(field, default, _) when field in @top_level_keys do
    quote do
      Talon.Config.get_app()
      |> Application.get_env(:talon, [])
      |> Keyword.get(unquote(field), unquote(default))
    end
  end
  defmacro get_env(concern, key, default) do
    quote do
      Keyword.get(Talon.Config.get_all_env(unquote(concern)), unquote(key), unquote(default))
    end
  end

  defmacro get_env(field) do
    quote do
      Talon.Config.get_env(unquote(field), nil)
    end
  end


  for {key, default} <- @top_level_config do
    defmacro unquote(key)() do
      key = unquote(key)
      default = unquote(default)
      quote do
        Talon.Config.get_env(unquote(key), unquote(default))
      end
    end
  end

  for {key, _default} <- @overridable_config do
    defmacro unquote(key)(concern) do
      # default = unquote(default)
      key = unquote(key)
      quote do
        Talon.Config.get_env(unquote(concern), unquote(key)) ||
          Talon.Config.get_env(unquote(key))
      end
    end
  end

  defmacro themes(concern) do
    quote do
      concern = unquote(concern)
      [Talon.Config.theme(concern) | Talon.Config.get_env(concern, :themes) || []]
    end
  end

  defmacro generators(option, default \\ []) do
    quote do
      Keyword.get (Talon.Config.get_env(:generators) || []), unquote(option), unquote(default)
    end
  end

  defmacro resources(concern) do
    quote do
      Talon.Config.get_env(unquote(concern), :resources)
    end
  end

  defmacro pages(concern) do
    quote do
      Talon.Config.get_env(unquote(concern), :pages)
    end
  end

end
