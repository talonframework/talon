defmodule Talon.Plug.LoadConcern do
  @moduledoc """
  Creates a new conn.assigns.talon and loads the context into it
  """
  import Plug.Conn

  @behaviour Plug

  def init(opts) do
    Enum.into opts, %{}
  end


  def call(conn, opts) do
    talon = conn.assigns[:talon] || %{}
    concern = opts[:concern] || talon[:concern] || raise("concern option required")
    schema = concern.schema(conn.params["resource"])
    # require IEx
    # IEx.pry
    unless schema do
      raise Phoenix.Router.NoRouteError, conn: conn, router: __MODULE__
    end
    talon_resource = concern.talon_resource(conn.params["resource"])
    assign conn, :talon, Enum.into([talon_resource: talon_resource, schema: schema], talon)
  end

end
