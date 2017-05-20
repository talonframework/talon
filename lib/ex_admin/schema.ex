defmodule ExAdmin.Schema do

  def primary_key(%{from: {_, mod}} = query) do
    adapter(mod).primary_key(query)
  end

  def primary_key(module) when is_atom(module) do
    adapter(module).primary_key(module)
  end

  def primary_key(resource) do
    adapter(resource.__struct__).primary_key(resource)
  end

  def get_id(resource) do
    adapter(resource.__struct__).get_id(resource)
  end

  def type(%{from: {_, mod}} = query, key) do
    adapter(mod).type(query, key)
  end
  def type(module, key) when is_atom(module) do
    adapter(module).type(module, key)
  end

  def type(resource, key) do 
    adapter(resource.__struct__).type(resource, key)
  end

  def get_intersection_keys(resource, assoc_name) do
    adapter(resource.__struct__).get_intersection_keys(resource, assoc_name) 
  end

  defp adapter(module) do
    base = 
      :ex_admin
      |> Application.get_env(:module)
      
    Module.concat([base, Admin]).admin_resource(module)
    |> apply(:adapter, [])
  end
end