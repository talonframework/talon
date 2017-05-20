defmodule ExAdmin.Plug.AdminResource do

  import Plug.Conn

  @behaviour Plug

  def init(opts) do
    Enum.into opts, %{}
  end


  def call(conn, opts) do
    ex_admin = conn.assigns[:ex_admin] || %{}
    admin = opts[:admin] || ex_admin[:admin] || raise("admin option required")
    schema = admin.schema(conn.params["resource"])
    admin_resource = admin.admin_resource(conn.params["resource"])
    assign conn, :ex_admin, Enum.into([admin_resource: admin_resource, schema: schema], ex_admin)
  end

end