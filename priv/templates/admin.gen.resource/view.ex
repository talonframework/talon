defmodule <%= theme_module %>.<%= resource <> "View" %> do
  # defmodule AdminLte.UserView do
  use Phoenix.View, root: "web/templates/admin/<%= theme_name %>"
  use ExAdmin.Web, :view
end
