defmodule <%= base %>.AdminResourceController do
  use <%= base %>.Web, :controller
  use ExAdmin.Controller, repo: <%= base %>.Repo, admin: <%= base %>.Admin

  plug ExAdmin.Plug.AdminResource
  plug ExAdmin.Plug.LoadResource
  plug ExAdmin.Plug.LoadAssociations
  plug ExAdmin.Plug.LoadAssociatedCollections when action in [:new, :edit]
  plug ExAdmin.Plug.Theme
  plug ExAdmin.Plug.Layout
  plug ExAdmin.Plug.View
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
