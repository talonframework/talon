defmodule Talon.Page do
  @moduledoc """
  Define an Talon managed page

  """

  @type module_or_struct :: atom | struct

  defmacro __using__(opts) do

    context = opts[:context]

    quote do
      @__context__ unquote(context) || (Module.split(__MODULE__) |> hd |> Module.concat(nil))

      @spec index_card_title() :: String.t
      def index_card_title do
        Inflex.Pluralize.pluralize "#{Module.split(__MODULE__) |> List.last}"
      end

      @doc """
      Returns a list of links for each of the Talon dashboards.

      Note: This function is overridable
      """
      @spec dashboard_paths(Map.t) :: [Tuple.t]
      def dashboard_paths(%{talon: talon} = _talon) do
        talon.dashboard_names()
        |> Enum.map(fn dashboard ->
          {Talon.Utils.titleize(dashboard),  "/talon/#{dashboard}"}
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
          schema = talon_resource.schema() # TODO: let view determine presentation name for a resource (DJS)
          {Talon.Utils.titleize(schema) |> Inflex.Pluralize.pluralize, Talon.Utils.talon_resource_path(schema, :index)}
        end)
      end

      @doc """
      Return the Talon context.
      """
      @spec context() :: atom
      def context, do: @__context__

      defoverridable [
        context: 0, resource_paths: 1, dashboard_paths: 1, index_card_title: 0
      ]
    end
  end
end
