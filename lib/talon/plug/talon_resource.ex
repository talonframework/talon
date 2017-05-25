defmodule Talon.Plug.TalonResource do

  import Plug.Conn

  @behaviour Plug

  def init(opts) do
    Enum.into opts, %{}
  end


  def call(conn, opts) do
    talon = conn.assigns[:talon] || %{}
    talon = opts[:talon] || talon[:talon] || raise("talon option required")
    schema = talon.schema(conn.params["resource"])
    talon_resource = talon.talon_resource(conn.params["resource"])
    assign conn, :talon, Enum.into([talon_resource: talon_resource, schema: schema], talon)
  end

end
