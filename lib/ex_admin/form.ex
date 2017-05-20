defmodule ExAdmin.Form do
  import Phoenix.HTML.Form
  def input_builder({f, a}, field, opts) do
    # a.adapter().input_builder(a, resource, opts)
    struct = f.data.__struct__
    associations = associations(struct)
    type = 
      case associations[field] do
        nil   -> struct.__schema__(:type, field) 
        assoc -> assoc
      end
    build_input({a, f}, field, type, opts)
  end

  defp build_input({_a, f}, field, :string, opts) do
    text_input(f, field, opts)    
  end
  defp build_input({_a, f}, field, type, opts) when type in ~w(integer id)a do
    text_input(f, field, [{:type, :number} | opts])    
  end
  defp build_input({_a, f}, field, :boolean, opts) do
    text_input(f, field, opts)    
  end
  defp build_input({a, f}, field, %Ecto.Association.BelongsTo{} = assoc, opts) do
    {collection, opts} = Keyword.pop(opts, :collection)
    assoc_list = Keyword.get(a[:associations] || [], field, [])
    collection = collection || assoc_list
    # require IEx
    # IEx.pry
    select(f, field, collection)
  end

  defp build_input({_a, f}, field, type, opts) do
    IO.puts "build_input unknow #{inspect type} for #{inspect field}"
    text_input(f, field, opts)    
  end

  # defp defn_and_adapter(%{__struct__: module}), 
  #   do: defn_and_adapter(module)

  # defp defn_and_adapter(module) when is_atom(module) do
  #   base = 
  #     :ex_admin
  #     |> Application.get_env(:module)
      
  #   Module.concat([base, Admin]).admin_resource(module)
  #   |> apply(:adapter, [])
  # end

  defp get_all(f, queryable) do
    # f.source.repo.all queryable
    IO.inspect Map.from_struct(f.source), label: "f.source..."
    # IO.inspect(f.impl, label: "f.impl ...")
    []
  end

  def associations(struct) when is_map(struct) do
    associations struct.__struct__
  end
  def associations(module) do
    :associations
    |> module.__schema__
    |> Enum.map(fn field -> 
      case module.__schema__(:association, field) do
        %Ecto.Association.BelongsTo{owner_key: owner_key} = assoc -> 
          {owner_key, assoc}
        %Ecto.Association.Has{field: field} = assoc -> 
          {field, assoc}
      end
    end)
  end
end