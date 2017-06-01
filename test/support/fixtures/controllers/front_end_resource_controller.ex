defmodule TestTalon.FrontEndResourceController do
  use TestTalon.Web, :controller
  use Talon.Controller, repo: TestTalon.Repo, context: TestTalon.FrontEnd

  plug Talon.Plug.LoadContext
  plug Talon.Plug.LoadResource
  plug Talon.Plug.LoadAssociations
  plug Talon.Plug.LoadAssociatedCollections when action in [:new, :edit]
  plug Talon.Plug.Theme
  plug Talon.Plug.Layout
  plug Talon.Plug.View
end
