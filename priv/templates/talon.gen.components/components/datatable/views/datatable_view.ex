defmodule <%= base %>.<%= concern %>.<%= theme_module %>.<%= web_namespace %>DatatableView do
  use <%= base %>.Talon.Web, which: :component_view<%= view_opts %>
  use Talon.Components.Datatable, __MODULE__

end
