defmodule Talon.Plug.LoadAssociations do
  @moduledoc """
  This plug is reponsible for loading the association data into the parms.
  It has not been implemented yet. See talon/lib/params_associations.ex for
  an example of the implemnation required.
  """

  @behaviour Plug

  def init(opts) do
    Enum.into opts, %{}
  end


  def call(conn, _opts) do
    # talon = conn.assigns[:talon]
    # repo = opts[:repo] || talon[:repo]
    # talon = opts[:talon] || talon[:talon] || raise("talon option required")
    # resource = conn.assigns.resource
    conn
  end

end
