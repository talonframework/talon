defmodule <%= base %>.<%= concern %> do
  @moduledoc """
  Admmin Endpoint/Concern.

  This module contains a number of default functions which are all
  overridable. It is also used for namespacing configuration.

  You may create multiple instances of the module if you would like to
  have different behaviour for an Talon managed front end an a separate
  Talon managed backend.

  If you are using Talon in differnt umbrella apps, create a separate
  module (differnt name) for each app that uses Talon.
  """
  use Talon.Concern, otp_app: <%= inspect app %>
  <%= if boilerplate do %>
  # Here is a list of the functions that you can override:

  # @spec base() :: atom
  # def base, do: @__base__

  # @spec repo() :: atom
  # def repo, do: @__repo__

  # def resource_map, do: @__resource_map__

  # def resources, do: @__resources__

  # def resource_names, do: @__resource_map__ |> Map.keys

  # def schema(resource_name) do
  #   talon_resource(resource_name).schema()
  # end

  # def schema_names do
  #   resource_names()
  #   |> Enum.map(fn name ->
  #     name |> schema |> Module.split |> List.last
  #   end)
  # end

  # def talon_resource(resource_name) when is_binary(resource_name) do
  #   @__resource_map__[resource_name]
  # end
  # def talon_resource(struct) when is_atom(struct) do
  #   @__resource_to_talon__[struct]
  # end
  # def talon_resource(resource) when is_map(resource) do
  #   @__resource_to_talon__[resource.__struct__]
  # end

  # def resource_schema(resource_name) when is_binary(resource_name) do
  #   {String.to_atom(resource_name), talon_resource(resource_name)}
  # end

  # def controller_action(resource_name) do
  #   {resource_name, talon_resource} = resource_schema(resource_name)
  #   schema = talon_resource.schema()
  #   {schema, resource_name, Application.get_env(:talon, :theme)}
  # end

  # def template_path_name(resource_name) do
  #   @__view_path_names__[resource_name]
  # end

  <% end %>
end
