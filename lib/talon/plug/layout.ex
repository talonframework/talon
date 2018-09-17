defmodule Talon.Plug.Layout do

  @behaviour Plug

  require Talon.Config, as: Config

  def init(opts) do
    Enum.into opts, %{}
  end

  def call(conn, opts) do
    layout =
      case opts[:layout] do
        nil ->
          talon = conn.assigns[:talon]
          theme = opts[:theme] || conn.assigns.talon.theme
          mod = Module.concat [talon.concern, Inflex.camelize(theme), Config.web_namespace(:talon), LayoutView]
          {mod, "app.html"}
        layout ->
          layout
      end
    Phoenix.Controller.put_layout conn, layout
  end

end
