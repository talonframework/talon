defmodule <%= theme_module %>.<%= resource <> "View" %> do
  # defmodule TalonLte.UserView do
  use Phoenix.View, root: "web/templates/talon/<%= theme_name %>"
  use Talon.Web, :view
end
