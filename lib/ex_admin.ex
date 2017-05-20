defmodule ExAdmin do
  @moduledoc """
  

  First, some termonolgy:

  * schema - The name of a give schema. .i.e. TestExAdmin.Simple
  * admin_resource - the admin module for a given schema. .i.e. TestExAdmin.ExAdmin.Simple

  ## resource_map
  
      iex> TestExAdmin.Admin.resource_map()["simples"]
      TestExAdmin.ExAdmin.Simple

      iex> TestExAdmin.Admin.resources() |> hd
      TestExAdmin.ExAdmin.Simple

      iex> TestExAdmin.Admin.resource_names() |> hd
      "simples"

      iex> TestExAdmin.Admin.schema("simples")
      TestExAdmin.Simple

      iex> TestExAdmin.Admin.schema_names() |> hd
      "Simple"

      iex> TestExAdmin.Admin.admin_resource("simples")
      TestExAdmin.ExAdmin.Simple

      iex> TestExAdmin.Admin.admin_resource(TestExAdmin.Simple)
      TestExAdmin.ExAdmin.Simple
      
      iex> TestExAdmin.Admin.admin_resource(%TestExAdmin.Simple{})
      TestExAdmin.ExAdmin.Simple

      iex> TestExAdmin.Admin.controller_action("simples")
      {TestExAdmin.Simple, :simples, nil}

      iex> TestExAdmin.Admin.base()
      TestExAdmin

      iex> TestExAdmin.Admin.template_path_name("simples")
      "simple"
  """

  defmacro __using__(opts) do
    otp_app = opts[:otp_app]
    unless otp_app do
      raise "Must provide :otp_app option"
    end

    quote location: :keep do
      @__resources__  Application.get_env(:ex_admin, :resources, [])

      @__resource_map__  for mod <- @__resources__, into: %{}, 
        do: {Module.split(mod) |> List.last() |> to_string |> Inflex.underscore |> Inflex.Pluralize.pluralize, mod}
      
      @__view_path_names__ for {plural, _} <- @__resource_map__, into: %{}, do: {plural, Inflex.singularize(plural)}

      @__resource_to_admin__ for resource <- @__resources__, do: {resource.schema(), resource}

      def base do 
        Application.get_env(:ex_admin, :base)
      end

      def resource_map, do: @__resource_map__

      def resources, do: @__resources__

      def resource_names, do: @__resource_map__ |> Map.keys

      def schema(resource_name) do 
        admin_resource(resource_name).schema()
      end

      def schema_names do
        resource_names()
        |> Enum.map(fn name -> 
          name |> schema |> Module.split |> List.last
        end)
      end

      def admin_resource(resource_name) when is_binary(resource_name) do
        @__resource_map__[resource_name]
      end
      def admin_resource(struct) when is_atom(struct) do
        @__resource_to_admin__[struct]
      end
      def admin_resource(resource) when is_map(resource) do
        @__resource_to_admin__[resource.__struct__]
      end

      def resource_schema(resource_name) when is_binary(resource_name) do
        {String.to_atom(resource_name), admin_resource(resource_name)}
      end

      def controller_action(resource_name) do
        {resource_name, resource_module} = resource_schema(resource_name)
        schema = resource_module.schema()
        {schema, resource_name, Application.get_env(:ex_admin, :theme)}
      end

      def template_path_name(resource_name) do
        @__view_path_names__[resource_name]
      end
    end
  end
 
  @doc """
  Return the app's base module.

  ## Examples

      iex> ExAdmin(MyAdmin.Admin)
      MyAdmin
  """
  # @spec app_module(atom) :: atom
  # def app_module(admin) do
  #   Application.get_env(admin.module)
  # end
end
