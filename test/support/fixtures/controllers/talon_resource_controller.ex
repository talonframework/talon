defmodule TestTalon.TalonResourceController do
  use TestTalon.Web, :controller
  use Talon.Controller, repo: TestTalon.Repo, context: TestTalon.Talon

  plug Talon.Plug.TalonResource
  plug Talon.Plug.LoadResource
  plug Talon.Plug.LoadAssociations
  plug Talon.Plug.LoadAssociatedCollections when action in [:new, :edit]
  plug Talon.Plug.Theme
  plug Talon.Plug.Layout
  plug Talon.Plug.View
end
