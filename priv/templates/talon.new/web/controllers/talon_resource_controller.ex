defmodule <%= base %>.<%= web_namespace %>TalonResourceController do
  use <%= base %>.Web, :controller
  use Talon.Controller, repo: <%= base %>.Repo, concern: <%= base %>.<%= concern %>

  plug Talon.Plug.LoadConcern
  plug Talon.Plug.LoadResource
  plug Talon.Plug.LoadAssociations
  plug Talon.Plug.LoadAssociatedCollections when action in [:new, :edit]
  plug Talon.Plug.Theme
  plug Talon.Plug.Layout
  plug Talon.Plug.View
  <%= if boilerplate do %>
  # Each of the controller actions can be overridden in this module

  # Override the show action
  # def show(conn, params) do
  #   IO.inspect params, label: params
  #   conn
  #   |> assign(:something, "something")
  #   |> super(paams)
  # end
  <% end %>
end
