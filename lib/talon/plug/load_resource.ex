defmodule Talon.Plug.LoadResource do

  import Plug.Conn

  @behaviour Plug

  def init(opts) do
    Enum.into opts, %{}
  end

  def call(conn, opts) do
    talon = conn.assigns[:talon]
    repo = opts[:repo] || talon[:repo]
    talon = opts[:talon] || talon[:talon] || raise("talon option required")
    schema = talon.schema(conn.params["resource"])
    conn
    |> Phoenix.Controller.action_name
    |> handle_action(conn, repo, schema)
  end

  defp handle_action(action, conn, _repo, schema) when action in [:index, :search] do
    talon_resource = Talon.View.talon_resource(conn)
    schema
    |> talon_resource.search(conn.params, action)
    |> talon_resource.query(conn.params, action)
    |> talon_resource.preload(conn.params, action)
    |> talon_resource.paginate(conn.params, action)
    |> case do
      {:page, page} ->
        conn
        |> assign(:resources, page.entries)
        |> assign(:page, struct(page, entries: []))
      {_, resources} ->
        assign(conn, :resources, resources)
    end
    |> assign(:resource, schema)
  end

  defp handle_action(action, conn, repo, schema) when action in [:show, :edit, :delete] do
    talon_resource = Talon.View.talon_resource(conn)
    resource =
      schema
      |> talon_resource.query(conn.params, action)
      |> talon_resource.preload(conn.params, action)
      |> repo.one
    assign(conn, :resource, resource)
  end

  defp handle_action(action, conn, _repo, schema) do
    talon_resource = Talon.View.talon_resource(conn)
    resource = talon_resource.preload(schema.__struct__, conn.params, action)
    assign(conn, :resource, resource)
  end

end
