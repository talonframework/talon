defmodule TestTalon.TalonPageController do
  use TestTalon.Web, :controller
  use Talon.PageController, context: TestTalon.Talon

  plug Talon.Plug.TalonResource
  plug Talon.Plug.Theme
  plug Talon.Plug.Layout
  plug Talon.Plug.View  # TODO: consider PageView? (DJS)
end
