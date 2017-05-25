defmodule Talon.Plug.TalonResource do

  import Plug.Conn

  @behaviour Plug

  def init(opts) do
    Enum.into opts, %{}
  end


  def call(conn, opts) do
    # require IEx
    # IEx.pry
    talon = conn.assigns[:talon] || %{}
    context = opts[:talon] || talon[:talon] || raise("talon option required")
    schema = context.schema(conn.params["resource"])
    talon_resource = context.talon_resource(conn.params["resource"])
    assign conn, :talon, Enum.into([talon_resource: talon_resource, schema: schema], talon)
  end

end
