defmodule <%= theme_module %>.<%= web_namespace %>DatatableView do
  use Talon.Web, :component_view, theme: <%= theme_name %>, module: <%= theme_module %>.<%= web_namespace %>
  use Talon.Components.Datatable, __MODULE__

end
