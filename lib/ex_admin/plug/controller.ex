defmodule ExAdmin.Plug.Controller do

  def init(opts) do
    opts
  end

  def call(conn, opts) do
    scope = opts[:scope] || "admin"
    if hd(conn.path_info) == scope do
      # IO.inspect conn, label: "admin controller conn: "
      admin_controller(conn, opts)
    else
      conn
    end
  end

  def admin_controller(conn, opts) do
    resource = Macro.expand(@resource, __ENV__) || conn.params["resource"]
   
    conn
  end
end