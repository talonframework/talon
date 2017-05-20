defmodule ExAdmin.Plug.Layout do

  import Plug.Conn

  @behaviour Plug

  def init(opts) do
    Enum.into opts, %{}
  end

  def call(conn, opts) do
    ex_admin = conn.assigns[:ex_admin]
    mod = Module.concat ExAdmin, LayoutView
    layout = opts[:layout] || {mod, "app.html"}
    Phoenix.Controller.put_layout conn, layout
  end

end