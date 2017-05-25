defmodule Talon.Helpers do

  def model_name(%{__struct__: name}), do: model_name(name)
  def model_name(resource) when is_atom(resource) do
    if function_exported?(resource, :model_name, 0) do
      resource.model_name()
    else
      resource |> Talon.Utils.base_name |> Inflex.underscore()
    end
  end

end
