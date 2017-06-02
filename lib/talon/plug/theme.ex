defmodule Talon.Plug.Theme do

  import Plug.Conn

  @behaviour Plug

  def init(opts) do
    Enum.into opts, %{}
  end

  def call(conn, opts) do
    talon = conn.assigns[:talon]
    context = talon.talon
    theme = opts[:theme] || (Application.get_env(:talon, context, [])[:theme]) || "admin-lte"
    assign conn, :talon, Map.put(talon, :theme, theme)
  end

end
