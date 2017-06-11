defmodule <%= base %>.<%= web_namespace %>TalonPageController do
  use <%= base %>.Web, :controller

  use Talon.PageController, context: <%= base %>.Talon

  plug Talon.Plug.TalonResource
  plug Talon.Plug.Theme
  plug Talon.Plug.Layout
  plug Talon.Plug.View
  <%= if boilerplate do %>
  # TODO
  <% end %>
end
