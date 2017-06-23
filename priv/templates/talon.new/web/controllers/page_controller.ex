defmodule <%= base %>.<%= web_namespace %>TalonPageController do
  use <%= base %>.Web, :controller
  use Talon.PageController, concern: <%= base %>.<%= concern %>

  plug Talon.Plug.LoadConcern, concern: <%= base %>.<%= concern %>, web_namespace: <%= web_module %>
  plug Talon.Plug.Theme
  plug Talon.Plug.Layout, layout: <%= layout %>
  plug Talon.Plug.View
  <%= if boilerplate do %>
  # TODO
  <% end %>
end
