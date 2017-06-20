defmodule <%= target_module %>.<%= web_namespace %>LayoutView do
  use Talon.Web, which: :view<%= view_opts %>

  # TODO: use Talon.View and move function below there (DJS)

  alias __MODULE__

  def talon_resource(conn) do
    Talon.View.talon_resource(conn) # TODO: don't reference Talon.View directly (DJS)
  end

  def index_card_title(conn) do
    talon_resource(conn).index_card_title()
  end

  def page_paths(conn) do
    talon_resource(conn).page_paths(conn.assigns.talon)
  end

  def resource_paths(conn) do
    talon_resource(conn).resource_paths(conn.assigns.talon)
  end

  def nav_action_links(conn) do
    talon_resource(conn).nav_action_links(Phoenix.Controller.action_name(conn), conn.assigns[:resource])
  end
end
