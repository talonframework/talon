defmodule <%= base %>.<%= web_namespace %><%= concern %>PageController do
  use <%= base %>.Web, :controller
  use Talon.PageController, concern: <%= base %>.<%= concern %>

  plug Talon.Plug.LoadConcern, concern: <%= base %>.<%= concern %>, web_namespace: <%= web_module %>
  plug Talon.Plug.Theme
  plug Talon.Plug.Layout, layout: <%= layout %>
  plug Talon.Plug.View

  # TODO: We want @resource always set. For index, set to nil. Use plug to set (wasn't working)?
  def index(conn, params) do
    conn
    |> assign(:resource, nil)
    |> super(params)
  end

  <%= if boilerplate do %>
  # TODO
  <% end %>
end
