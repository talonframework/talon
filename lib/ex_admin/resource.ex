defmodule ExAdmin.Resource do
  defmacro __using__(opts) do
    schema = opts[:schema]
    unless schema do
      raise ":schema is required"
    end

    schema_adapter = opts[:adapter] || Application.get_env(:ex_admin, :schema_adapter)
    unless schema_adapter do
      raise "schema_adapter required"
    end

    quote do
      @__module__ unquote(schema)
      @__adapter__ unquote(schema_adapter)

      def index_columns do
        @__module__.__schema__(:fields) -- ~w(id inserted_at updated_at)a
      end

      def form_columns do
        @__module__.__schema__(:fields) -- ~w(id inserted_at updated_at)a
      end

      def index_card_title do
        "#{Module.split(@__module__) |> List.last}s"
      end

      def form_card_title(name) do
        "#{Module.split(@__module__) |> List.last} #{name}"
      end

      def tool_bar do
        "Listing of #{index_card_title()}"
      end

      def route_name do
        Module.split(@__module__) |> to_string |> String.downcase |> Inflex.Pluralize.pluralize
      end
      
      def schema, do: @__module__

      def adapter, do: @__adapter__ 

      defoverridable [index_columns: 0, index_card_title: 0, form_card_title: 1, tool_bar: 0, route_name: 0, adapter: 0, form_columns: 0]
    end
  end
end