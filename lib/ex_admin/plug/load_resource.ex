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

  defp handle_action(:index, conn, repo, schema) do
    admin_resource = ExAdmin.View.admin_resource(conn)
    resources = admin_resource.preload(repo.all(schema), :index)

    conn
    |> assign(:resource, schema)
    |> assign(:resources, resources)
  end
  defp handle_action(action, conn, repo, schema) when action in [:show, :edit, :delete] do
    admin_resource = ExAdmin.View.admin_resource(conn)
    # IO.inspect conn.params, label: "handle_action params"
    resource = admin_resource.preload(repo.get(schema, conn.params["id"]), action)
    assign(conn, :resource, resource)
  end
  defp handle_action(action, conn, _repo, schema) do
    admin_resource = ExAdmin.View.admin_resource(conn)
    # IO.puts "action: #{inspect action}, params: #{inspect conn.params}"
    resource = admin_resource.preload(schema.__struct__, action)
    assign(conn, :resource, resource)
  end

end
