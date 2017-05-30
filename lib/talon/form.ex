defmodule Talon.Form do
  import Phoenix.HTML.Form
  def input_builder({f, a}, field, opts) do
    # a.adapter().input_builder(a, resource, opts)

    context = a.talon
    struct = f.data.__struct__
    associations = Talon.Schema.associations(struct)
    type =
      case associations[field] do
        nil   -> struct.__schema__(:type, field)
        assoc -> assoc
      end
    type = context.schema_field_type struct, field, type
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
    context = a.talon
    {collection, opts} = Keyword.pop(opts, :collection)
    assoc_list = Keyword.get(a[:associations] || [], field, [])
    collection = for item <- collection || assoc_list,
      do: collection_tuple(context, item)
    select(f, field, collection, opts)
  end

  defp build_input({_a, f}, field, type, opts) do
    IO.puts "build_input unknow #{inspect type} for #{inspect field}"
    text_input(f, field, opts)
  end

  defp collection_tuple(context, item) do
    {context.display_name(item), context.primary_key(item)}
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
