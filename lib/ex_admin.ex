defmodule ExAdmin do
  @moduledoc """
  Documentation for ExAdmin.
  """

  defmacro __using__(_opts) do
    quote location: :keep do
      @__resources__  Application.get_env(:ex_admin, :resources, [])

      @__resource_map__  for mod <- @__resources__, into: %{}, 
        do: {Module.split(mod) |> List.last() |> to_string |> String.downcase |> Inflex.Pluralize.pluralize, mod}

      @__resource_to_admin__ for resource <- @__resources__, do: {resource.schema(), resource}

      def resource_map, do: @__resource_map__

      def resources, do: @__resources__

      def resource_names, do: @__resource_map__ |> Map.keys

      def schema(resource_name), do: @__resource_map__[resource_name]


      def admin_resource(struct) when is_atom(struct) do
        @__resource_to_admin__[struct]
      end

      def admin_resource(resource) when is_map(resource) do
        @__resource_to_admin__[resource.__struct__]
      end

      def resource_schema(resource_name) when is_binary(resource_name) do
        {String.to_atom(resource_name), schema(resource_name)}
      end

    end
  end
end
