defmodule Talon.Resource do
  @moduledoc """
  Mix-in for Talon managed resource.
  """

  @type module_or_struct :: atom | struct

  defmacro __using__(opts) do

    repo = opts[:repo]

    quote location: :keep do
      require Talon.Config, as: Config
      alias Talon.Utils

      opts = unquote(opts)

      @__concern__   opts[:concern]
      @__domain__    opts[:domain] || "talon"
      @__module__    opts[:schema]

      unless @__module__ do
        raise ":schema is required"
      end

      @__adapter__ opts[:adapter] || Config.schema_adapter(@__concern__)
      unless @__adapter__ do
        raise "schema_adapter required"
      end

      @__repo__ unquote(repo) || @__concern__.repo()# ||  Module.concat(@__concern__, Repo)
      @__paginate__ opts[:paginate] || Config.paginate(__MODULE__) || true
      @__params_key__  Module.split(@__module__) |> List.last |> to_string |> Inflex.underscore
      @__route_name__ @__params_key__ |> Inflex.Pluralize.pluralize

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

      @spec display_schema_columns(Plug.Conn.t, atom) :: List.t
      def display_schema_columns(conn, _action) do
        @__module__.__schema__(:fields) -- concern().schema_column_filter(conn)
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
      # TODO: do we still want this (and other) view-related requests to pass through Resource?
      # @spec get_schema_field(:index | :show | :form, Struct.t, String.t) :: atom
      # def get_schema_field(action, resource, name) do
      #   Talon.View.get_resource_field(@__concern__, action, resource, name)
      # end

      @spec header_title(Plug.Conn.t, Module.t) :: String.t
      def header_title(conn, resource \\ nil) do
        case action = Phoenix.Controller.action_name(conn) do
          :show  -> dgettext @__domain__, "%{type} %{title}", type: display_name(), title: resource_title(resource)
          :new   -> dgettext @__domain__, "%{action} %{type}", action: Utils.titleize(action), type: display_name()
          :edit  -> dgettext @__domain__, "%{action} %{title}", action: Utils.titleize(action), title: resource_title(resource)
          :index -> dgettext @__domain__, "%{plural_type}", plural_type: display_name_plural()
          _      -> dgettext @__domain__, "Unknown action"
        end
      end

      @spec toolbar_title() :: String.t
      def toolbar_title() do
        dgettext @__domain__, "%{type} listing", type: display_name()
      end

      @spec route_name() :: String.t
      def route_name, do: @__route_name__

      @spec params_key() :: String.t
      def params_key, do: @__params_key__

      @spec schema() :: Module.t
      def schema, do: @__module__

      def all(schema, _conn, _action), do: schema

      @spec adapter() :: Module.t
      def adapter, do: @__adapter__

      @spec paginate() :: boolean
      def paginate, do: @__paginate__

      @doc """
      Preload your associations.

      Note: This function is overridable
      """
      @spec preload(Ecto.Query.t | Struct.t, Map.t, atom) :: Ecto.Query.t
      def preload(%Ecto.Query{} = query, _params, action) do
        # associations = schema().__schema__(:associations)
        Ecto.Query.preload(query, ^associations_to_preload())
      end
      def preload(resource, _params, action) do
        # associations =  schema().__schema__(:associations)
        repo().preload(resource, associations_to_preload())
      end

      def all_associations, do: schema().__schema__(:associations)

      def cardinality_one_associations do
        all_associations()
        |> Enum.reduce([], fn(field, acc) ->
          if schema().__schema__(:association, field).cardinality in [:one], do: [field | acc], else: acc
        end)
      end

      def associations_to_preload, do: cardinality_one_associations()

      def concern_scope(query, conn, action), do: concern().concern_scope(query, conn, action)

      def default_scope(query, params, action), do: query

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

      def named_scope(query, params, _action) do
        case params["scope"] do
          nil -> query
          scope -> (scope_queries()[String.to_atom(scope)] || &null_query/1).(query)
        end
      end

      def scope_queries(), do: []

      def null_query(query), do: query

      def format_scope_name(scope_name), do: Talon.Utils.titleize(scope_name)

      @doc """
      Paginate the query
      """
      @spec paginate(Ecto.Query.t, Map.t, atom) :: Ecto.Query.t
      def paginate(query, params, action) when action in [:index, :search] do
        if @__paginate__, do: {:page, repo().paginate(query, params)}, else: {:resources, repo().all(query)}
      end

      @doc """
      Return the Talon concern.
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
        Talon.Search.search(conn, __MODULE__, schema(), conn.params["search_terms"])
      end

      @spec search(Struct.t, Plug.Conn.t, Map.t) :: Ecto.Query.t
      def search(schema, conn, params) do
        Talon.Search.search(conn, __MODULE__, schema, params["search_terms"])
      end

      @spec search(Struct.t, Plug.Conn.t, Map.t, atom) :: Ecto.Query.t
      def search(schema, conn, params, action) when action in [:search, :index] do
        search(schema, conn, params)
      end
      def search(schema, _conn, _params, _), do: schema

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

      @spec resource_title(Module.t) :: String.t
      def resource_title(resource) do
        Map.get(resource, name_field())
      end

      def themes do
        Config.themes(@__concern__)
      end

      def display_name do
        dgettext @__domain__, "%{name}", name: Talon.Utils.titleize(@__module__)
      end

      def display_name_plural do
        dgettext @__domain__, "%{name}", name: Inflex.Pluralize.pluralize(display_name())
      end

      defoverridable [
        params_key: 0, display_schema_columns: 2, default_scope: 3,
        toolbar_title: 0, route_name: 0, repo: 0,
        adapter: 0, render_column_name: 2, preload: 3, concern: 0, concern_scope: 3,
        paginate: 3, query: 3, search: 1, search: 3, search: 4, schema_types: 0, name_field: 0,
        themes: 0, display_name: 0, display_name_plural: 0, header_title: 2, header_title: 1, resource_title: 1,
        all_associations: 0, associations_to_preload: 0, scope_queries: 0, named_scope: 3,
        format_scope_name: 1, all: 3
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
