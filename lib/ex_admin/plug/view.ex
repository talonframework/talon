defmodule ExAdmin.Plug.View do

  import Plug.Conn

  @behaviour Plug

  def init(opts) do
    Enum.into opts, %{}
  end

  def call(conn, opts) do
    view = 
      case opts[:view] do
        nil -> 
          ex_admin = conn.assigns[:ex_admin]
          schema = ex_admin.schema |> Module.split |> List.last
          Module.concat ExAdmin, schema <> "View"
        view -> 
          view
      end
    Phoenix.Controller.put_view conn, view
  end

end