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

    context = opts[:context]

    schema_adapter = opts[:adapter] || Application.get_env(:ex_admin, :schema_adapter)
    unless schema_adapter do
      raise "schema_adapter required"
    end

    repo = opts[:repo]

    quote do
      @__module__ unquote(schema)
      @__adapter__ unquote(schema_adapter)
      @__context__ unquote(context) || (Module.split(__MODULE__) |> hd |> Module.concat(nil))
      @__repo__ unquote(repo) || @__context__.repo() ||  Module.concat(@__context__, Repo)

      @doc """
      Return the schema columns for rending on all pages.

      By default, the id, inserted_at, and updated_at fields are removed
      for all page types.

      Page types include:

      - :index
      - :show
      - :form

      ## Examples

      You can override this function is your resource file. If overriding a specific
      action, make sure you add a default clause that calls `super(action)`.

          defmodule MyApp.ExAdmin.User do
            use ExAdmin.Register, schema: MyApp.User

            # add :id, :updated_at, :inserted_at to the index page
            def display_schema_name(:index) do
              [:id | super(:index)] ++ [:updated_at, :inserted_at]
            end

            # use the defaults for the remaining pages.
            def display_schema_name(action) do
              super(action)
            end
          end

      """
      @spec display_schema_columns(atom) :: List.t
      def display_schema_columns(_action) do
        @__module__.__schema__(:fields) -- ~w(id inserted_at updated_at)a
      end

      @doc """
      Translates column atoms into human title format.

      ## Examples

          iex> ExAdmin.Resource.render_column_name(:index, :first_name)
          "First Name"
          iex> ExAdmin.Resource.render_column_name(:index, :state_id)
          "State"
      """
      @spec render_column_name(atom, atom) :: String.t
      def render_column_name(_action, field) do
        field = to_string(field)
        if String.ends_with?(field, "_id") do
          String.replace(field, "_id", "")
        else
          field
        end
        |> ExAdmin.Utils.titleize
      end

      @doc """

      """
      @spec get_schema_field(:index | :show | :form, Struct.t, String.t) :: atom
      def get_schema_field(_action, resource, name) do
        ExAdmin.View.get_resource_field(resource, name)
      end

      @spec index_card_title() :: String.t
      def index_card_title do
        # TODO: find a resuable approach here
        Inflex.Pluralize.pluralize "#{Module.split(@__module__) |> List.last}"
      end

      @spec form_card_title(String.t) :: String.t
      def form_card_title(name) do
        "#{Module.split(@__module__) |> List.last} #{name}"
      end

      @spec tool_bar() :: String.t
      def tool_bar do
        "Listing of #{index_card_title()}"
      end

      @spec route_name() :: String.t
      def route_name do
        Module.split(@__module__) |> to_string |> Inflex.underscore |> Inflex.Pluralize.pluralize
      end

      @spec params_key() :: String.t
      def params_key do
        Module.split(@__module__) |> List.last |> to_string |> Inflex.underscore
      end

      @spec schema() :: Module.t
      def schema, do: @__module__

      @spec adapter() :: Module.t
      def adapter, do: @__adapter__

      # TODO: I think the view helpers belong in a diffent module. Putting them here for now.

      @doc """
      Return the action likes for a given controller action and resource.

      Returns a list of action link tuples for give page and scema resource.

      Note: This function is overridable
      """
      @spec nav_action_links(atom, Struct.t | Module.t) :: List.t
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
      @spec resource_paths(Map.t) :: [Tuple.t]
      def resource_paths(%{admin: admin} = _ex_admin) do
        admin.resources()
        |> Enum.map(fn admin_resource ->
          schema = admin_resource.schema()
          {ExAdmin.Utils.titleize(schema) |> Inflex.Pluralize.pluralize, ExAdmin.Utils.admin_resource_path(schema, :index)}
        end)
      end

      @doc """
      Preload your associations.

      Note: This function is overridable
      """
      @spec preload(Struct.t, atom) :: Struct.t
      def preload(resource, _action) do
        associations =  schema().__schema__(:associations)
        repo().preload(resource, associations)
      end

      @doc """
      Returrn the Admin context.
      """
      @spec context() :: atom
      def context, do: @__context__

      @doc """
      Return the Repo
      """
      @spec repo() :: atom
      def repo, do: @__repo__

      defoverridable [
        resource_paths: 1, nav_action_links: 2, params_key: 0, display_schema_columns: 1,
        index_card_title: 0, form_card_title: 1, tool_bar: 0, route_name: 0, repo: 0,
        adapter: 0, render_column_name: 2, get_schema_field: 3, preload: 2, context: 0
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

  def resource_module(admin, _module) do
    ExAdmin.app_module(admin)
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
