defmodule ExAdmin do
  @moduledoc """
  Documentation for ExAdmin.
  """

  defmacro __using__(opts) do
    quote do
      @__resources__  Application.get_env(:ex_admin, :resources, [])

      @__resource_map__  for mod <- @__resources__, into: %{}, 
        do: {Module.split(mod) |> List.last() |> to_string |> String.downcase |> Inflex.Pluralize.pluralize, mod}

      def resource_map, do: @__resource_map__

      def resources, do: @__resources__

      def resource_names, do: @__resource_map__ |> Map.keys

      def schema(resource_name), do: @__resource_map__[resource_name]

      def resource_schema(resource_name) when is_binary(resource_name) do
        {String.to_atom(resource_name), schema(resource_name)}
      end

    end
  end
end
