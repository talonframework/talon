defmodule ExAdmin.Plug.LoadAssociations do
  @moduledoc """
  This plug is reponsible for loading the association data into the parms.
  It has not been implemented yet. See ex_admin/lib/params_associations.ex for
  an example of the implemnation required.
  """

  import Plug.Conn

  @behaviour Plug

  def init(opts) do
    Enum.into opts, %{}
  end


  def call(conn, _opts) do
    # ex_admin = conn.assigns[:ex_admin]
    # repo = opts[:repo] || ex_admin[:repo]
    # admin = opts[:admin] || ex_admin[:admin] || raise("admin option required")
    # resource = conn.assigns.resource
    conn
  end

end