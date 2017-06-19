defmodule <%= base %>.Talon.<%= page %> do
  @moduledoc """
  Use this file to configure your Talon page.

  TBD
  """
  use Talon.Page, context: <%= "#{base}.Talon" %>
  <%= if boilerplate do %>
    # TODO
  <% end %>
end
