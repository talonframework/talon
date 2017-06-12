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
          prefix =
            (talon[:talon_resource] || talon[:talon_page])
            |> Module.split |> List.last

          Module.concat [theme, Talon.web_namespace(), prefix <> "View"]
        view ->
          view
      end
    Phoenix.Controller.put_view conn, view
  end

end
