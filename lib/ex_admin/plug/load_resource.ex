defmodule ExAdmin.Plug.LoadResource do

  import Plug.Conn

  @behaviour Plug

  def init(opts) do
    Enum.into opts, %{}
  end

  def call(conn, opts) do
    ex_admin = conn.assigns[:ex_admin]
    repo = opts[:repo] || ex_admin[:repo]
    admin = opts[:admin] || ex_admin[:admin] || raise("admin option required")
    schema = admin.schema(conn.params["resource"])
    conn
    |> Phoenix.Controller.action_name
    |> handle_action(conn, repo, schema)
  end

  defp handle_action(action, conn, repo, schema) when action in [:index, :search] do
    admin_resource = ExAdmin.View.admin_resource(conn)
    schema
    |> admin_resource.search(conn.params, action)
    |> admin_resource.query(conn.params, action)
    |> admin_resource.preload(conn.params, action)
    |> admin_resource.paginate(conn.params, action)
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
    admin_resource = ExAdmin.View.admin_resource(conn)
    resource =
      schema
      |> admin_resource.query(conn.params, action)
      |> admin_resource.preload(conn.params, action)
      |> repo.one
    assign(conn, :resource, resource)
  end

  defp handle_action(action, conn, _repo, schema) do
    admin_resource = ExAdmin.View.admin_resource(conn)
    resource = admin_resource.preload(schema.__struct__, conn.params, action)
    assign(conn, :resource, resource)
  end

end
