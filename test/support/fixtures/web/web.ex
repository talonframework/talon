defmodule TestExAdmin.Web do

  def view do
    quote do
      use Phoenix.View, root: "test/support/templates"
      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

    end
  end

  def controller do
    quote do
      use Phoenix.Controller

      alias ExAdminTest.Repo
      import Ecto
      import Ecto.Query

      import TestExAdmin.Router.Helpers
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end