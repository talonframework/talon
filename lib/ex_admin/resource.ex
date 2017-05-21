defmodule ExAdmin.Resource do
  @moduledoc """
  Define an ExAdmin managed resource


  """

  @type module_or_struct :: atom | struct

  defmacro __using__(opts) do
    schema = opts[:schema]
    unless schema do
      raise ":schema is required"
    end

    schema_adapter = opts[:adapter] || Application.get_env(:ex_admin, :schema_adapter)
    unless schema_adapter do
      raise "schema_adapter required"
    end

    quote do
      @__module__ unquote(schema)
      @__adapter__ unquote(schema_adapter)

      def index_columns do
        @__module__.__schema__(:fields) -- ~w(id inserted_at updated_at)a
      end

      def get_index_field(resource, name) do
        ExAdmin.View.get_resource_field(resource, name)
      end

      def get_show_field(resource, name) do
        ExAdmin.View.get_resource_field(resource, name)
      end

      def form_columns do
        @__module__.__schema__(:fields) -- ~w(id inserted_at updated_at)a
      end

      def index_card_title do
        # TODO: find a resuable approach here
        Inflex.Pluralize.pluralize "#{Module.split(@__module__) |> List.last}"
      end

      def form_card_title(name) do
        "#{Module.split(@__module__) |> List.last} #{name}"
      end

      def tool_bar do
        "Listing of #{index_card_title()}"
      end

      def route_name do
        Module.split(@__module__) |> to_string |> Inflex.underscore |> Inflex.Pluralize.pluralize
      end

      def params_key do
        Module.split(@__module__) |> List.last |> to_string |> Inflex.underscore
      end

      def schema, do: @__module__

      def adapter, do: @__adapter__

      # TODO: I think the view helpers belong in a diffent module. Putting them here for now.

      @doc """
      Return the action likes for a given controller action and resource.

      Returns a list of action link tuples for give page and scema resource.

      Note: This function is overridable
      """
      def nav_action_links(action, resource) when action in [:index, :edit] do
        [ExAdmin.Resource.nav_action_link(:new, resource)]
      end
      def nav_action_links(:show, resource) do
        [
          ExAdmin.Resource.nav_action_link(:edit, resource),
          ExAdmin.Resource.nav_action_link(:new, resource),
          ExAdmin.Resource.nav_action_link(:delete, resource)
        ]
      end
      def nav_action_links(_action, _resource) do
        []
      end

      @doc """
      Returns a list of links for each of the ExAdmin managed resources.

      Note: This function is overridable
      """
      def resource_paths(%{admin: admin} = _ex_admin) do
        admin.resources()
        |> Enum.map(fn admin_resource ->
          schema = admin_resource.schema()
          {ExAdmin.Utils.titleize(schema) |> Inflex.Pluralize.pluralize, ExAdmin.Utils.admin_resource_path(schema, :index)}
        end)
      end

      defoverridable [
        resource_paths: 1, nav_action_links: 2, params_key: 0, index_columns: 0,
        index_card_title: 0, form_card_title: 1, tool_bar: 0, route_name: 0,
        adapter: 0, form_columns: 0
      ]
    end

  end

  @doc """
  Return the resource module.

  Looks up the resource module from either a given scema module or a schema
  struct.

  ## Examples

      iex> ExAdmin.Resource.resource_module(MyApp.User)
      MyApp.ExAdmin.User

      iex> ExAdmin.Resource.resource_module(%MyApp.User{})
      MyApp.ExAdmin.User

  """
  @spec resource_module(atom, module_or_struct) :: atom

  def resource_module(admin, %{__struct__: module}), do: resource_module(admin, module)

  def resource_module(admin, module) do
    admin
    |> ExAdmin.app_module()
  end

  @doc """
  Return the action link tuple for an action link

  Returns the action link for `:new`, `:edit`, and `:delete` actions.

  ## Examples

      iex> ExAdmin.Resource.nav_action_link(:new, TestExAdmin.Simple)
      {:new, "New Simple", "/admin/simples/new"}

      iex> ExAdmin.Resource.nav_action_link(:new, %TestExAdmin.Simple{id: 1})
      {:new, "New Simple", "/admin/simples/new"}

      iex> ExAdmin.Resource.nav_action_link(:edit, %TestExAdmin.Simple{id: 1})
      {:new, "Edit Simple", "/admin/simples/1/edit"}

      iex> ExAdmin.Resource.nav_action_link(:delete, %TestExAdmin.Simple{id: 1})
      {:new, "Edit Simple", "/admin/simples/1"}
  """
  @spec nav_action_link(atom, atom | struct) :: {atom, String.t, String.t}
  def nav_action_link(action, resource_or_module) do
    {resource, module} =
      case resource_or_module do
        %{__struct__: module} -> {resource_or_module, module}
        module -> {module.__struct__, module}
      end
    path =
      case action do
        :new -> ExAdmin.Utils.admin_resource_path(module, :new)
        :edit ->ExAdmin.Utils.admin_resource_path(resource, :edit)
        :delete -> ExAdmin.Utils.admin_resource_path(resource, :delete)
      end
    title = String.capitalize(to_string(action)) <> " " <> ExAdmin.Utils.titleize(resource)
    {action, title, path}
  end

end
