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
    resources = repo.all schema
    conn
    |> assign(:resource, schema)
    |> assign(:resources, resources)
  end
  defp handle_action(action, conn, repo, schema) when action in [:show, :edit, :delete] do
    # IO.inspect conn.params, label: "handle_action params"
    resource = repo.get schema, conn.params["id"]
    assign(conn, :resource, resource)
  end
  defp handle_action(action, conn, _repo, schema) do
    # IO.puts "action: #{inspect action}, params: #{inspect conn.params}"
    assign(conn, :resource, schema.__struct__)
  end

end
