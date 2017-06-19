defmodule Talon.Page do
  @moduledoc """
  Define an Talon managed page

  """

  @type module_or_struct :: atom | struct

  defmacro __using__(opts) do

    context = opts[:context]

    quote do
      @__context__ unquote(context) || (Module.split(__MODULE__) |> hd |> Module.concat(nil))

      # TODO: too specific to template. Move to view.
      @spec index_card_title() :: String.t
      def index_card_title, do: title()

      @doc """
      Returns a list of links for each of the Talon managed pages.

      Note: This function is overridable
      """
      @spec page_paths(Map.t) :: [Tuple.t]
      def page_paths(%{talon: talon} = _talon) do  # TODO: move to concern and use this approach for resource_paths (DJS)
        talon.pages |> Enum.map(&{apply(&1, :title, []),  "/talon/pages/#{apply(&1, :name, [])}"})  # TODO: remove apply (DJS)
      end

      @doc """
      Returns a list of links for each of the Talon managed resources.

      Note: This function is overridable
      """
      @spec resource_paths(Map.t) :: [Tuple.t]
      def resource_paths(%{talon: talon} = _talon) do
        talon.resources()
        |> Enum.map(fn talon_resource ->
          schema = talon_resource.schema()
          # TODO: let resource determine presentation name (DJS)
          {Talon.Utils.titleize(schema) |> Inflex.Pluralize.pluralize, Talon.Utils.talon_resource_path(schema, :index)}
        end)
      end

      @doc """
      Return the Talon context.
      """
      @spec context() :: atom
      def context, do: @__context__

      @spec title() :: String.t
      def title, do: name() |> Talon.Utils.titleize

      # TODO: perhaps resource_name, module_name
      @spec name() :: String.t
      def name, do: __MODULE__ |> Module.split |> List.last() |> to_string |> Inflex.underscore

      defoverridable [
        context: 0, resource_paths: 1, page_paths: 1, index_card_title: 0, title: 0, name: 0
      ]
    end
  end
end
