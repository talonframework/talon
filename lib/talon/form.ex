defmodule Talon.Form do
  import Phoenix.HTML.Form
  def input_builder({f, a}, field, opts) do
    # a.adapter().input_builder(a, resource, opts)

    concern = a.concern
    struct = f.data.__struct__
    associations = Talon.Schema.associations(struct)
    type =
      case associations[field] do
        nil   -> struct.__schema__(:type, field)
        assoc -> assoc
      end
    type = concern.schema_field_type struct, field, type
    build_input({a, f}, field, type, opts)
  end

  defp build_input({_a, f}, field, :string, opts) do
    text_input(f, field, opts)
  end

  defp build_input({_a, f}, field, :text, opts) do
    textarea(f, field, opts)
  end

  defp build_input({_a, f}, field, type, opts) when type in ~w(integer id)a do
    text_input(f, field, [{:type, :number} | opts])
  end

  defp build_input({_a, f}, field, :boolean, _opts) do
    checkbox(f, field)
  end

  defp build_input({a, f}, field, %Ecto.Association.BelongsTo{} = _assoc, opts) do
    concern = a.concern
    {collection, opts} = Keyword.pop(opts, :collection)
    assoc_list = Keyword.get(a[:associations] || [], field, [])
    collection = for item <- collection || assoc_list,
      do: collection_tuple(concern, item)
    select(f, field, collection, opts)
  end

  # TODO: This is a hack and does not work with updates/changes. Need a solution
  defp build_input({_a, f}, field, :map, opts) do
    source = f.source
    resource = source.data
    resource = Map.put(resource, field, Poison.encode!(Map.get(resource, field)))
    new_f =
      f
      |> struct(data: resource)
      |> struct(source: struct(source, data: resource))

    text_input new_f, field, opts
  end

  defp build_input({_a, f}, field, {:array, :string}, opts) do
    source = f.source
    _resource = source.data

    value = if f.params["#{field}"] != [] do
              f.params["#{field}"]
            else
              Enum.join(Map.get(source.data, field) || [], "\n")
            end

    opts = opts
            |> Keyword.put(:value, value)
            |> Keyword.put(:placeholder, "value1\nvalue2...")

    textarea f, field, opts
  end

  defp build_input({_a, _f}, field, type, _opts) do
    IO.puts "build_input unknow #{inspect type} for #{inspect field}"
    "unknown type"
  end

  defp collection_tuple(concern, item) do
    {concern.display_name(item), concern.primary_key(item)}
  end
  # defp defn_and_adapter(%{__struct__: module}),
  #   do: defn_and_adapter(module)

  # defp defn_and_adapter(module) when is_atom(module) do
  #   base =
  #     :talon
  #     |> Application.get_env(:module)

  #   Module.concat([base, Talon]).talon_resource(module)
  #   |> apply(:adapter, [])
  # end

  # defp get_all(f, queryable) do
  #   # f.source.repo.all queryable
  #   IO.inspect Map.from_struct(f.source), label: "f.source..."
  #   # IO.inspect(f.impl, label: "f.impl ...")
  #   []
  # end

end
