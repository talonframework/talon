defmodule ExAdmin.Plug.Theme do

  import Plug.Conn

  @behaviour Plug

  def init(opts) do
    Enum.into opts, %{}
  end

  def call(conn, opts) do
    ex_admin = conn.assigns[:ex_admin]
    admin = ex_admin.admin
    theme = opts[:theme] || (Application.get_env(:ex_admin, admin, [])[:theme]) || "admin_lte"
    assign conn, :ex_admin, Map.put(ex_admin, :theme, theme)
  end

end