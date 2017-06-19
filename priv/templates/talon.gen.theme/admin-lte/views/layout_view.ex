defmodule <%= base %>.<%= concern %>.<%= target_module %>.<%= web_namespace %>LayoutView do
  use <%= base %>.Talon.Web, which: :view<%= view_opts %>

  def resource_paths(conn, _talon_resource) do
    concern = conn.assigns.talon.concern
    concern.resources()
    |> Enum.map(fn tr ->
      {tr.display_name_plural(), concern.resource_path(tr.schema, :index)}
    end)
  end

  def nav_action_links(conn) do
    Talon.Concern.nav_action_links(conn)
  end
end
