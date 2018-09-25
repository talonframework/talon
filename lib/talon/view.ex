defmodule Talon.View do
  @moduledoc """
  View related API functions

  TBD
  """

  alias Talon.{Schema, Utils}

  defmacro __using__(_) do
    quote location: :keep  do
      import Phoenix.HTML.Tag
      import Phoenix.HTML.Link

      @spec concern(Plug.Conn.t) :: atom
      def concern(conn) do
        conn.assigns.talon.concern
      end

      @doc """
      Helper to return the current `talon_resource` module.

      Extract the `talon_resource` module from the conn.assigns
      """
      @spec talon_resource(Plug.Conn.t) :: atom
      def talon_resource(conn) do
        conn.assigns.talon.talon_resource
      end

      @doc """
      Return the humanized field name and the field value.

      Reflect on the field type. Return the association display name or
      the field value for non associations.

      For associations:
      * Use the Schema's `display_name/1` if defined
      * Use the schema's `:name` field if it exists
      * Otherwise, return "No Display Name"

      TODO: Need to use overridable decorators to resolve value types
      """

      # TODO: should this be get_formatted_resource_field?
      @spec get_resource_field(Module.t, :index | :show | :form, Struct.t, atom) :: {String.t, any}
      def get_resource_field(concern, action, resource, field_name) do
        {Talon.Utils.titleize(to_string field_name), get_formatted_field_value(concern, action, resource, field_name)}
      end

      @spec get_formatted_field_value(Module.t, :index | :show | :form, Struct.t, atom) :: String.t
      def get_formatted_field_value(concern, action, resource, field_name) do
        get_resource_field_value(concern, action, resource, field_name) |> format_field_value
      end

      @spec format_field_value({Struct.t, any}) :: String.t
      def format_field_value({:simple, value}) do
        format_data(value)
      end
      def format_field_value({:to_one, {value, path}}) do
        Talon.Utils.link_to(value, path)
      end

      @spec get_resource_field_value(Module.t, :index | :show | :form, Struct.t, atom) :: {atom, any}
      def get_resource_field_value(concern, action, resource, field_name) do
        resource.__struct__
        |> Schema.associations()
        |> Keyword.get(field_name)
        |> get_resource_field_value(concern, action, resource, field_name)
      end

      @spec get_resource_field_value(Struct.t, Module.t, :index | :show | :form, Struct.t, atom) :: {atom, any}
      def get_resource_field_value(%{field: field, related: _related} = _assoc, concern, _action, resource, _field_name) do
        assoc_resource = Map.get(resource, field)
        value =
          if association_loaded? assoc_resource do
            {:to_one, {concern.display_name(assoc_resource), concern.resource_path(assoc_resource, :show)}}
          else
            {:simple, concern.messages_backend().not_loaded()}
          end
      end
      def get_resource_field_value(nil, _concern, _action, resource, field_name) do
        {:simple, Map.get(resource, field_name)}
      end
      def get_resource_field_value(_assoc, _concern, _action, _resource, _field_name) do
        {:simple, "unknown type"}
      end

      @doc """
      Check if the value of an association is loaded
      """
      @spec association_loaded?(any) :: boolean
      def association_loaded?(%Ecto.Association.NotLoaded{}), do: false
      def association_loaded?(%{}), do: true
      def association_loaded?(_), do: false

      # TODO: this is only temporary. Need to use orverridable decorator concept here
      def format_data(%DateTime{} = dt), do: dt |> Utils.to_datetime |> Utils.format_datetime
      def format_data(data) when is_binary(data), do: data
      def format_data(data) when is_number(data), do: data
      def format_data(data), do: inspect(data)

      # TODO: Consider renaming page_paths/resource_paths as page/resource_links. (DJS)
      # TODO: return the resource type (:page/:backed) as well. With that, we could offer a single resource_links.
      #       Could return the resource module as well for easy handling of additional callbacks, if needed. (DJS)

      def resource_paths(conn), do: concern(conn).resource_paths(conn)

      def resource_path(conn, resource, action, opts \\ []) do
        Talon.Concern.resource_path conn, resource, action, opts
      end

      def page_paths(conn) do
        concern(conn).page_paths(conn)
      end

      def search_path(conn) do
        resource_path(conn, :search, [""])
      end

      def search_value(conn) do
        conn.params["search_terms"]
      end

      def nav_action_links(conn) do
        Talon.Concern.nav_action_links(conn)
      end

      def header_title(conn, resource \\ nil) do
        talon_resource(conn).header_title(conn, resource)
      end

      def index_toolbar_title(conn) do
        talon_resource(conn).toolbar_title()
      end

      def show_actions(_conn, resource) do
        resource.adapter().primary_key(resource.schema)
      end

      def scope_links(%Plug.Conn{} = conn) do
        if r = talon_resource(conn), do: scope_links(conn, r), else: []
      end

      def scope_links(conn, resource) do
        resource.scope_queries()
        |> Enum.map(fn {scope_name, query_fn} ->
          {format_scope_name(resource, scope_name), scope_path(conn, resource, scope_name)}
        end)
      end

      def scope_path(conn, resource, scope_name) do
        concern(conn).resource_path(resource.schema(), :index, [[scope: scope_name]])
      end

      def format_scope_name(resource, scope_name), do: resource.format_scope_name(scope_name)

      defoverridable([
        talon_resource: 1, resource_paths: 1, nav_action_links: 1,
        resource_path: 4, header_title: 2, get_resource_field: 4,
        get_formatted_field_value: 4, format_field_value: 1, scope_links: 1,
        scope_links: 2, format_scope_name: 2,  get_resource_field_value: 4, get_resource_field_value: 5
      ])

    end
  end

  def view_module(conn, view) do
    Module.concat [
      Talon.Concern.concern(conn),
      Talon.View.theme_module(conn),
      Talon.Concern.web_namespace(conn),
      view
    ]
  end

  @doc """
  Helper to return the current `talon_resource` module.

  Extract the `talon_resource` module from the conn.assigns
  """
  @spec talon_resource(Plug.Conn.t) :: atom
  def talon_resource(conn) do
    conn.assigns.talon[:talon_resource]
  end

  # TODO: should this be get_formatted_resource_field?
  @spec get_resource_field(Plug.Conn.t, :index | :show | :form, Struct.t, atom) :: {String.t, any}
  def get_resource_field(conn, action, resource, field_name) do
    view_module(conn).get_resource_field(conn.assigns.talon.concern, action, resource, field_name)
  end

  # TODO: should this be get_formatted_resource_field_value?
  @spec get_resource_field_value(Plug.Conn.t, :index | :show | :form, Struct.t, atom) :: any
  def get_resource_field_value(conn, action, resource, field_name) do
    view_module(conn).get_formatted_field_value(conn.assigns.talon.concern, action, resource, field_name)
  end

  @doc """
  Extract the params_key from the conn
  """
  @spec params_key(Plug.Conn.t) :: String.t
  def params_key(conn) do
    talon_resource(conn).params_key()
  end

  @doc """
  Extract the repo form the conn
  """
  @spec repo(Plug.Conn.t) :: Struct.t
  def repo(conn) do
    conn.assigns.talon.repo
  end

  @doc """
  Get the current theme module.

  ## Examples

      iex> Talon.View.theme_module(%{assigns: %{talon: %{theme: "admin-lte"}}})
      AdminLte
  """
  @spec theme_module(Plug.Conn.t) :: atom
  def theme_module(conn) do
    conn.assigns.talon.theme
    |> Inflex.camelize
    |> Module.concat(nil)
  end

  @spec view_module(Plug.Conn.t) :: atom
  def view_module(conn), do: Phoenix.Controller.view_module(conn)
end
