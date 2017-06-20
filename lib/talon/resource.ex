defmodule Talon.Resource do
  @moduledoc """
  Define an Talon managed resource


  """

  @type module_or_struct :: atom | struct

  defmacro __using__(opts) do
    schema = opts[:schema]
    unless schema do
      raise ":schema is required"
    end

    context = opts[:context]

    schema_adapter = opts[:adapter] || Application.get_env(:talon, :schema_adapter)
    unless schema_adapter do
      raise "schema_adapter required"
    end

    repo = opts[:repo]
    paginate = opts[:paginate] || Application.get_env(:talon, :paginage)

    quote do
      @__module__ unquote(schema)
      @__adapter__ unquote(schema_adapter)
      @__context__ unquote(context) || (Module.split(__MODULE__) |> hd |> Module.concat(nil))
      @__repo__ unquote(repo) || @__context__.repo() ||  Module.concat(@__context__, Repo)
      @__paginate__ unquote(paginate) || true
      @__params_key__  Module.split(@__module__) |> List.last |> to_string |> Inflex.underscore
      @__route_name__ @__params_key__ |> Inflex.Pluralize.pluralize

      require Ecto.Query

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

          defmodule MyApp.Talon.User do
            use Talon.Register, schema: MyApp.User

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

          iex> Talon.Resource.render_column_name(:index, :first_name)
          "First Name"
          iex> Talon.Resource.render_column_name(:index, :state_id)
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
        |> Talon.Utils.titleize
      end

      @doc """

      """
      @spec get_schema_field(:index | :show | :form, Struct.t, String.t) :: atom
      def get_schema_field(_action, resource, name) do
        Talon.View.get_resource_field(resource, name)
      end

      @spec index_card_title() :: String.t
      def index_card_title do
        # TODO: find a resuable approach here
        Inflex.Pluralize.pluralize "#{Module.split(@__module__) |> List.last}"
      end

      @spec form_card_title(String.t) :: String.t
      def form_card_title(resource) do
        name =
          resource
          |> Map.get(Talon.Resource.name_field(resource.__struct__))
        "#{Module.split(@__module__) |> List.last} #{name}"
      end

      @spec tool_bar() :: String.t
      def tool_bar do
        "Listing of #{index_card_title()}"
      end

      @spec route_name() :: String.t
      def route_name, do: @__route_name__

      @spec params_key() :: String.t
      def params_key, do: @__params_key__

      @spec schema() :: Module.t
      def schema, do: @__module__

      @spec adapter() :: Module.t
      def adapter, do: @__adapter__

      @spec paginate() :: boolean
      def paginate, do: @__paginate__

      # TODO: I think the view helpers belong in a diffent module. Putting them here for now.

      @doc """
      Return the action likes for a given controller action and resource.

      Returns a list of action link tuples for give page and scema resource.

      Note: This function is overridable
      """
      @spec nav_action_links(atom, Struct.t | Module.t) :: List.t
      def nav_action_links(action, resource) when action in [:index, :edit] do
        [Talon.Resource.nav_action_link(:new, resource)]
      end
      def nav_action_links(:show, resource) do
        [
          Talon.Resource.nav_action_link(:edit, resource),
          Talon.Resource.nav_action_link(:new, resource),
          Talon.Resource.nav_action_link(:delete, resource)
        ]
      end
      def nav_action_links(_action, _resource) do
        []
      end

      # TODO: Consider renaming page_paths/presource_paths as page/resource_links.

      # TODO: return the resource type (:page/:backed) as well. With that, we could collapse to just resource_links.
      #   Could return the resource module as well for easy handling of additional callbacks, if needed

      @doc """
      Returns a list of links for each of the Talon managed pages.

      Note: This function is overridable
      """
      @spec page_paths(Map.t) :: [Tuple.t]
      def page_paths(%{talon: talon} = _talon) do  # TODO: move to concern (DJS)
        talon.page_names()
        |> Enum.map(&{Talon.Utils.titleize(&1),  "/talon/pages/#{&1}"})
      end

      @doc """
      Returns a list of links for each of the Talon managed resources.

      Note: This function is overridable
      """
      @spec resource_paths(Map.t) :: [Tuple.t]
      def resource_paths(%{talon: talon} = _talon) do  # TODO: move to concern (DJS)
        talon.resources()
        |> Enum.map(fn talon_resource ->
          schema = talon_resource.schema() # TODO: let resource determine presentation name (DJS)
          {Talon.Utils.titleize(schema) |> Inflex.Pluralize.pluralize, Talon.Utils.talon_resource_path(schema, :index)}
        end)
      end

      @doc """
      Preload your associations.

      Note: This function is overridable
      """
      @spec preload(Ecto.Query.t | Struct.t, Map.t, atom) :: Ecto.Query.t
      def preload(query, _params, action) when action in [:index, :show, :edit, :delete, :search] do
        associations = schema().__schema__(:associations)
        Ecto.Query.preload(query, ^associations)
      end
      def preload(resource, _params, _action) do
        associations =  schema().__schema__(:associations)
        repo().preload(resource, associations)
      end

      @doc """
      Hook for intercepting the query
      """
      @spec query(Ecto.Query.t, Map.t, atom) :: Ecto.Query.t
      def query(query, %{"id" => id}, action), do: Ecto.Query.where(query, id: ^id)
      def query(query, %{"order" => order}, :index) when not is_nil(order) do
        order = Talon.Components.Datatable.sort_column_order(order)
        Ecto.Query.order_by(query, ^order)
      end
      def query(query, _parmas, action), do: query

      @doc """
      Paginate the query
      """
      @spec paginate(Ecto.Query.t, Map.t, atom) :: Ecto.Query.t
      def paginate(query, params, action) when action in [:index, :search] do
        if @__paginate__, do: {:page, repo().paginate(query, params)}, else: {:resources, repo().all(query)}
      end

      @doc """
      Return the Talon context.
      """
      @spec context() :: atom
      def context, do: @__context__

      @doc """
      Return the Repo
      """
      @spec repo() :: atom
      def repo, do: @__repo__

      @spec search(Plug.Conn.t) :: Ecto.Query.t
      def search(conn) do
        Talon.Search.search(__MODULE__, schema(), conn.params["search_terms"])
      end

      @spec search(Struct.t, Map.t) :: Ecto.Query.t
      def search(schema, params) do
        Talon.Search.search(__MODULE__, schema, params["search_terms"])
      end

      @spec search(Struct.t, Map.t, atom) :: Ecto.Query.t
      def search(schema, params, :search) do
        search(schema, params)
      end
      def search(schema, _params, _), do: schema

      @doc """
      Override schema type.

      Use this function to override field type rendering.

      ## Examples

          # define a string field as a textaread
          def schema_types, do: [body: :text]
      """
      @spec schema_types() :: List.t
      def schema_types, do: []

      @doc """
      Find the display name field.

      Used for getting the name to display in belongs_to associations.

      Check to see if the schema has a name field. If not, finds
      the first string field
      """
      @spec name_field() :: atom
      def name_field do
        Talon.Resource.name_field @__module__
      end

      defoverridable [
        resource_paths: 1, nav_action_links: 2, params_key: 0, display_schema_columns: 1,
        index_card_title: 0, form_card_title: 1, tool_bar: 0, route_name: 0, repo: 0,
        adapter: 0, render_column_name: 2, get_schema_field: 3, preload: 3, context: 0,
        paginate: 3, query: 3, search: 1, search: 3, schema_types: 0, name_field: 0,
        page_paths: 1
      ]
    end

  end

  @doc """
  Return the action link tuple for an action link

  Returns the action link for `:new`, `:edit`, and `:delete` actions.

  ## Examples

      iex> Talon.Resource.nav_action_link(:new, TestTalon.Simple)
      {:new, "New Simple", "/talon/simples/new"}

      iex> Talon.Resource.nav_action_link(:new, %TestTalon.Simple{id: 1})
      {:new, "New Simple", "/talon/simples/new"}

      iex> Talon.Resource.nav_action_link(:edit, %TestTalon.Simple{id: 1})
      {:edit, "Edit Simple", "/talon/simples/1/edit"}

      iex> Talon.Resource.nav_action_link(:delete, %TestTalon.Simple{id: 1})
      {:delete, "Delete Simple", "/talon/simples/1"}
  """
  @spec nav_action_link(atom, atom | struct) :: {atom, String.t, String.t}  # TODO: move to view (DJS)
  def nav_action_link(action, resource_or_module) do
    {resource, module} =
      case resource_or_module do
        %{__struct__: module} -> {resource_or_module, module}
        module -> {module.__struct__, module}
      end
    path =
      case action do
        :new -> Talon.Utils.talon_resource_path(module, :new)
        :edit ->Talon.Utils.talon_resource_path(resource, :edit)
        :delete -> Talon.Utils.talon_resource_path(resource, :delete)
      end
    title = String.capitalize(to_string(action)) <> " " <> Talon.Utils.titleize(resource)
    {action, title, path}
  end

  @doc """
  Infer the name field from a schema.

  Infers with the following rules:

  * string :name field
  * first string field
  * first field

  ## Examples

      Talon.Resource.name_field(Post)
      :title

      Talon.Resource.name_field(%Post{})
      :title
  """
  @spec name_field(Struct.t | Module.t) :: atom

  def name_field(schema) when is_map(schema) do
    name_field schema.__struct__
  end
  def name_field(schema) when is_atom(schema) do
    types = schema.__schema__(:types)
    if types[:name] == :string do
      :name
    else
      types = Enum.find(types, &(elem(&1, 1) == :string))
      case types do
        nil ->
          schema.__schema__(:primary_key)
        {field, _} -> field
      end
    end
  end
end
