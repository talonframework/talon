defmodule <%= target_module %>.LayoutView do
  use Phoenix.View, root: "web/templates/talon/<%= target_name %>/"
  use Talon.Web, :view

end
