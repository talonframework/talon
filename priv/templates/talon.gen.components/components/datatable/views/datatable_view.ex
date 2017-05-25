defmodule <%= theme_module %>.DatatableView do
  use Phoenix.View, root: "web/templates/talon/<%= theme_name %>/components"
  use Talon.Web, :view
  use Talon.Components.Datatable, __MODULE__

end
