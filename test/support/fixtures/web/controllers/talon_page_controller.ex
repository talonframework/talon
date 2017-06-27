defmodule TestTalon.AdminPageController do
  use TestTalon.Web, :controller
  use Talon.PageController, concern: TestTalon.Admin

  plug Talon.Plug.LoadConcern, concern: TestTalon.Admin
  plug Talon.Plug.Theme
  plug Talon.Plug.Layout #, layout: {TestTalon.LayoutView, "app.html"} TODO: (DJS)
  plug Talon.Plug.View
end
