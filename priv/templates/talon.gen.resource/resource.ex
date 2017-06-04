defmodule <%= base %>.Talon.<%= scoped_resource %> do
  @moduledoc """
  Use this file to configure how Talon renders your resource.

  TBD
  """
  use Talon.Resource, schema: <%= "#{base}.#{scoped_resource}" %>, context: <%= "#{base}.Talon" %>
  <%= if boilerplate do %>
  # The above is all that is required to use Talon with defaults
  # If you would like to customize some of the features, wee the
  # commented boilerplate below

  # @doc """
  # Prelod the :state and :country associations
  # """
  # def preload(resource, _action) do
  #   <%= base %>.Repo.preload resource, [:some_association]
  # end

  # @doc """
  # Override the default index columns
  # Add the :id column on the index page and add the
  # :id, :updated_at and :inserted_at fields for the
  # show page. Use the default for the form page.
  # """
  # def display_schema_columns(:index) do
  #   [:id | super(:index)]
  # end
  # def display_schema_columns(:show) do
  #   [:id | super(:showw)] ++ [:updated_at, :inserted_at]
  # end
  # def display_schema_columns(action) do
  #   super(action)
  # end

  # @doc """
  # Override the default columm name rendering.
  # """
  # def render_column_name(_page, :zip_code), do: "Zip"
  # def render_column_name(_page, :street_num), do: "Num"
  # def render_column_name(page, field) do
  #   # handle redering for the remaining fields
  #   super(page, field)
  # end
  <% end %>
end
