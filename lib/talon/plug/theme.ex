defmodule Talon.Plug.Theme do

  import Plug.Conn

  @behaviour Plug

  def init(opts) do
    Enum.into opts, %{}
  end

  def call(conn, opts) do
    talon = conn.assigns[:talon]
    assign conn, :talon, Map.put(talon, :theme, opts[:theme] || talon.concern.theme())
  end

end
