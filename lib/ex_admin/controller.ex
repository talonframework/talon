defmodule ExAdmin.Controller do

  def admin_resource_schema(resource) when is_binary(resource) do
    admin_resource_schema String.to_atom(resource)
  end
  def admin_resource_schema(resource) do
    module = 
      :ex_admin
      |> Application.get_env(:resources, [])
      |> Keyword.get(resource, [])
    {resource, module}
  end
end