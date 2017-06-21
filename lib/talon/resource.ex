defmodule Talon.Resource do
  @moduledoc """
  Define an Talon managed resource


  """

  @type module_or_struct :: atom | struct

  defmacro __using__(opts) do

    repo = opts[:repo]

    quote do
      require Talon.Config, as: Config

      opts = unquote(opts)
      @__concern__ opts[:concern]

      @__module__ opts[:schema]
      unless @__module__ do
        raise ":schema is required"
      end

      @__adapter__ opts[:adapter] || Config.schema_adapter(@__concern__)
      unless @__adapter__ do
        raise "schema_adapter required"
      end

      @__repo__ unquote(repo) || @__concern__.repo()# ||  Module.concat(@__context__, Repo)
      @__paginate__ opts[:paginate] || Config.paginate(__MODULE__) || true
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
      Returrn the Talon concern.
      """
      @spec concern() :: atom
      def concern, do: @__concern__

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

      def themes do
        Config.themes(@__concern__)
      end

      def display_name do
        Talon.Utils.titleize(@__module__)
      end

      def display_name_plural do
        Inflex.Pluralize.pluralize display_name()
      end

      defoverridable [
        params_key: 0, display_schema_columns: 1,
        index_card_title: 0, form_card_title: 1, tool_bar: 0, route_name: 0, repo: 0,
        adapter: 0, render_column_name: 2, get_schema_field: 3, preload: 3, concern: 0,
        paginate: 3, query: 3, search: 1, search: 3, schema_types: 0, name_field: 0,
        themes: 0, display_name: 0, display_name_plural: 0
      ]
    end

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
