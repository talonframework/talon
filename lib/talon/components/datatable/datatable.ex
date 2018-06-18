defmodule Talon.Components.Datatable do
  @moduledoc """
  An Talon component for server side datatables.
  """
  defmacro __using__(opts) do
    quote do
      import unquote(__MODULE__)

      @doc """
      Render the search results
      """
      def render("search.html", opts) do
        render("table_and_paging.html", opts)
        |> Phoenix.HTML.safe_to_string
        |> Phoenix.HTML.raw
      end

      @doc """
      Render the datatable
      """
      @spec render_table(Plug.Conn.t, [Map.t]) :: any
      def render_table(conn, resources) do
        unquote(opts).render "datatable.html", conn: conn, resources: resources
      end

      defoverridable [render_table: 2]
    end
  end

  @doc """
  Get the column sort line of a sortable column.

  ## Examples

  ## Options

  * :key ("order") -- set the params key
  """
  @spec column_sort_link(Plug.Conn.t, atom, Keyword.t) :: String.t
  def column_sort_link(conn, name, opts \\ []) do
    key = opts[:key] || "order"
    order =
      case conn.params[key] do
        nil -> "_desc"
        value ->
          if String.ends_with?(value, "_asc"), do: "_desc", else: "_asc"
      end
    page = conn.params["page"] || "1"

    Talon.Concern.resource_path(conn, :index, [[order: "#{name}" <> order, page: page]])
  end

  @doc """
  Get the column heading class if the column is sorted.

  ## Examples

      iex> Talon.Components.Datatable.sort_column_class(%{params: %{"order" => "email_asc"}}, :email)
      " sorted-desc"

      iex> Talon.Components.Datatable.sort_column_class(%{params: %{"order" => "email_asc"}}, :address)
      ""

  ## Options

  * :key ("order") -- set the params key
  * :prefix (" sorted-")
  """
  @spec sort_column_class(Plug.Conn.t, atom, Keyword.t) :: String.t
  def sort_column_class(conn, name, opts \\ []) do
    key = opts[:key] || "order"
    prefix = opts[:prefix] || " sorted-"

    case sort_column_order(conn.params[key]) do
      [{:asc, ^name}] -> "#{prefix}desc"
      [{:desc, ^name}] -> "#{prefix}asc"
      _ -> ""
    end
  end

  @doc """
  Get the order and field tuple.

  ## Examples

      iex> Talon.Components.Datatable.sort_column_order("field_name_asc")
      {:asc, :field_name}

      iex> Talon.Components.Datatable.sort_column_order("name_desc")
      {:desc, :name}

  """
  @spec sort_column_order(String.t) :: List.t
  def sort_column_order(order) do
    cond do
      is_nil(order) ->
        []
      String.ends_with?(order, "_asc") ->
        [{:asc, order |> String.replace("_asc", "") |> String.to_atom}]
      String.ends_with?(order, "_desc") ->
        [{:desc, order |> String.replace("_desc", "") |> String.to_atom}]
      true ->
        []
    end
  end

end
