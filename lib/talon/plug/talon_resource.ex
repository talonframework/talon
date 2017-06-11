defmodule Talon.Plug.TalonResource do  # TODO: rename to something more generic TalonContext (TalonConcern)

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

    talon_resource = context.talon_resource(conn.params["resource"])
    if !talon_resource, do: talon_page = context.talon_page(conn.params["page"])

    assign conn, :talon, Enum.into([talon_resource: talon_resource, talon_page: talon_page], talon)
  end

end
