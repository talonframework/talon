defmodule Talon.Plug.View do

  @behaviour Plug

  def init(opts) do
    Enum.into opts, %{}
  end

  def call(conn, opts) do
    IO.inspect conn.assigns.talon, label: "talon..."
    view =
      case opts[:view] do
        nil ->
          talon = conn.assigns[:talon]
          theme = Inflex.camelize talon.theme
          schema = talon.schema |> Module.split |> List.last
          Module.concat [talon.concern, theme, conn.assigns.talon.web_namespace, schema <> "View"]
        view ->
          view
      end
    Phoenix.Controller.put_view conn, view
  end

end
