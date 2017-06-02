defmodule Talon.Plug.Layout do

  @behaviour Plug

  def init(opts) do
    Enum.into opts, %{}
  end

  def call(conn, opts) do
    theme = opts[:theme] || conn.assigns.talon.theme
    mod = Module.concat [Inflex.camelize(theme), Talon.Concern.web_namespace(), LayoutView]
    layout = opts[:layout] || {mod, "app.html"}
    Phoenix.Controller.put_layout conn, layout
  end

end
