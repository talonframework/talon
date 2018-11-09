defmodule Talon.Plug.View do

  @behaviour Plug

  def init(opts) do
    Enum.into opts, %{}
  end

  def call(conn, opts) do
    view =
      case opts[:view] do
        nil ->
          talon = conn.assigns[:talon]
          theme = Inflex.camelize talon.theme
          prefix = talon[:talon_resource] |> Module.split |> List.last
          web_namespace = Talon.Concern.web_namespace(conn)

          # FIXME: quick and dirty default view handling

          {:ok, modules} = :application.get_key(:admin, :modules)

          canonical_view = Module.concat [talon.concern, theme, web_namespace, prefix <> "View"]

          default_view = Module.concat [talon.concern, theme, web_namespace, "DefaultView"]

          all_mods_with_default_last = (modules -- [default_view]) ++ [default_view]

          all_mods_with_default_last |> Enum.find(fn(element) -> element in [canonical_view, default_view] end)
        view ->
          view
      end
    Phoenix.Controller.put_view conn, view
  end

end
