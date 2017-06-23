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

    talon_resource = concern.talon_resource(conn.params["resource"]) || concern.talon_page(conn.params["page"])

    talon_resource || raise("No Talon resource")

    assign conn, :talon, Enum.into([web_namespace: opts[:web_namespace],
      talon_resource: talon_resource, concern: concern], talon)
  end

end
