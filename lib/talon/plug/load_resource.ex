defmodule Talon.Plug.LoadResource do

  import Plug.Conn

  @behaviour Plug

  def init(opts) do
    Enum.into opts, %{}
  end

  def call(conn, opts) do
    talon = conn.assigns[:talon]
    repo = opts[:repo] || talon[:repo]
    concern = opts[:talon] || talon[:talon] || raise("talon option required")
    schema = concern.schema(conn.params["resource"])
    unless schema do
      raise Phoenix.Router.NoRouteError, conn: conn, router: __MODULE__
    end
    conn = conn |> assign(:talon, Enum.into([schema: schema], talon))
    conn
    |> Phoenix.Controller.action_name
    |> handle_action(conn, repo, schema)
  end

  defp handle_action(action, conn, _repo, schema) when action in [:index, :search] do
    talon_resource = Talon.View.talon_resource(conn)
    schema
    |> talon_resource.default_scope(conn.params, action)
    |> talon_resource.search(conn.params, action)
    |> talon_resource.query(conn.params, action)
    # |> talon_resource.preload(conn.params, action) # TODO: wasn't working before paginate with subqueries, so moved downstream
    |> talon_resource.paginate(conn.params, action)
    |> case do
      {:page, page} ->
        conn
        |> assign(:resources, page.entries |> talon_resource.preload(conn.params, action))
        |> assign(:page, struct(page, entries: []))
      {_, resources} ->
        assign(conn, :resources, resources |> talon_resource.preload(conn.params, action))
    end
    |> assign(:resource, schema)
  end

  defp handle_action(action, conn, repo, schema) when action in [:show, :edit, :delete, :update] do
    talon_resource = Talon.View.talon_resource(conn)
    resource =
      schema
      |> talon_resource.default_scope(conn.params, action)
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
