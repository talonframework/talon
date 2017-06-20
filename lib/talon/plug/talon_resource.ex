defmodule Talon.Plug.TalonResource do  # TODO: rename to something more generic like TalonConcern

  import Plug.Conn

  @behaviour Plug

  def init(opts) do
    Enum.into opts, %{}
  end

  def call(conn, opts) do
    talon = conn.assigns[:talon] || %{}
    context = opts[:talon] || talon[:talon] || raise("Talon option required")

    talon_resource = context.talon_resource(conn.params["resource"]) || context.talon_page(conn.params["page"])

    assign conn, :talon, Enum.into([talon_resource: talon_resource], talon)
  end
end
