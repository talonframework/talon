defmodule <%= target_module %>.LayoutView do
  use Phoenix.View, root: "web/templates/admin/<%= target_name %>/"
  use ExAdmin.Web, :view

end
