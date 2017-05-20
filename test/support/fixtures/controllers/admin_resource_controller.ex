defmodule TestExAdmin.AdminResourceController do
  use TestExAdmin.Web, :controller
  use ExAdmin.Controller, repo: TestExAdmin.Repo, admin: TestExAdmin.Admin

  plug ExAdmin.Plug.AdminResource
  plug ExAdmin.Plug.LoadResource
  plug ExAdmin.Plug.LoadAssociations
  plug ExAdmin.Plug.LoadAssociatedCollections when action in [:new, :edit]
  plug ExAdmin.Plug.Theme
  plug ExAdmin.Plug.Layout
  plug ExAdmin.Plug.View
end
