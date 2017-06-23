defmodule <%= base %>.<%= concern %>.<%= page %> do
  @moduledoc """
  Use this file to configure your Talon page.

  TBD
  """
  use Talon.Page, concern: <%= base %>.<%= concern %>
  <%= if boilerplate do %>
    # TODO
  <% end %>
end
