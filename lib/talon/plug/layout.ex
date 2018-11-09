defmodule Talon.Plug.Layout do

  @behaviour Plug

  def init(opts) do
    Enum.into opts, %{}
  end

  def call(conn, opts) do
    layout =
      case opts[:layout] do
        nil ->
          talon = conn.assigns[:talon]
          theme = opts[:theme] || conn.assigns.talon.theme
          web_namespace = Talon.Concern.web_namespace(conn)
          mod = Module.concat [talon.concern, Inflex.camelize(theme), web_namespace, LayoutView]
          {mod, "app.html"}
        layout ->
          layout
      end
    Phoenix.Controller.put_layout conn, layout
  end

end
