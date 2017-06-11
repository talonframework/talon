defmodule Talon.Page do
  @moduledoc """
  Define an Talon managed page

  """

  @type module_or_struct :: atom | struct

  defmacro __using__(opts) do

    context = opts[:context]

    quote do
      # @__module__ unquote(schema) # TODO: remove (DJS)

      @__context__ unquote(context) || (Module.split(__MODULE__) |> hd |> Module.concat(nil))

      # @__params_key__  Module.split(@__module__) |> List.last |> to_string |> Inflex.underscore  TODO: needed? (DJS)
      # @__route_name__ @__params_key__ |> Inflex.Pluralize.pluralize

      @spec index_card_title() :: String.t
      def index_card_title do
        # TODO: find a resuable approach here

        # Inflex.Pluralize.pluralize "#{Module.split(@__module__) |> List.last}"

        "Dashboard" # TODO: (DJS)
      end

    #   @spec route_name() :: String.t
    #   def route_name, do: @__route_name__

    #   @spec params_key() :: String.t
    #   def params_key, do: @__params_key__

      # @spec schema() :: Module.t    # TODO: remove (DJS)
      # def schema, do: nil # @__module__

      @doc """
      Returns a list of links for each of the Talon dashboards.

      Note: This function is overridable
      """
      @spec dashboard_paths(Map.t) :: [Tuple.t]
      def dashboard_paths(%{talon: talon} = _talon) do
        talon.dashboard_names()
        |> Enum.map(fn dashboard ->
          {Talon.Utils.titleize(dashboard),  "/talon/#{dashboard}"} # TODO: Talon.Utils.talon_dashboard_path (DJS)
        end)
      end

      @doc """
      Returns a list of links for each of the Talon managed resources.

      Note: This function is overridable
      """
      @spec resource_paths(Map.t) :: [Tuple.t]
      def resource_paths(%{talon: talon} = _talon) do
        talon.resources()
        |> Enum.map(fn talon_resource ->
          schema = talon_resource.schema() # TODO: let view determine presentation name for a resource
          {Talon.Utils.titleize(schema) |> Inflex.Pluralize.pluralize, Talon.Utils.talon_resource_path(schema, :index)}
        end)
      end

      @doc """
      Returrn the Talon context.
      """
      @spec context() :: atom
      def context, do: @__context__

      # TODO: (DJS)
    #   defoverridable [
    #     resource_paths: 1, nav_action_links: 2, params_key: 0, display_schema_columns: 1,
    #     index_card_title: 0, form_card_title: 1, tool_bar: 0, route_name: 0, repo: 0,
    #     adapter: 0, render_column_name: 2, get_schema_field: 3, preload: 3, context: 0,
    #     paginate: 3, query: 3, search: 1, search: 3, schema_types: 0, name_field: 0
    #   ]
    end
  end
end
