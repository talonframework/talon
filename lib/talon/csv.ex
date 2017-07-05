defmodule Talon.CSV do
  @moduledoc """
  """

  def write_file(resources, schema) do
    random_name =
      :crypto.strong_rand_bytes(16)
      |> Base.url_encode64
      |> binary_part(0, 16)
    file_path = System.tmp_dir() <> random_name
    file = File.open!(file_path, [:write, :utf8])
    rows = Enum.map(resources, fn(resource) ->
      build_row(resource, schema)
    end)

    [build_header(schema) | rows]
    |> CSV.encode
    |> Enum.each(&IO.write(file, &1))

    :ok = File.close(file)
    file_path
  end

  def normalize_schema(schema) do
    Enum.map schema, fn
      {name, fun} -> %{field: name, fun: fun}
      name when is_atom(name) -> %{field: name, fun: nil}
      map -> map
    end
  end

  defp build_header(schema) do
    for field <- schema, do: field[:field]
  end

  defp build_row(resource, schema) do
    Enum.reduce(schema, [], fn
      %{field: name, fun: nil}, acc ->
        [Map.get(resource, name) | acc]
      %{field: _name, fun: fun}, acc ->
        [fun.(resource) | acc]
    end)
    |> Enum.reverse
  end
end
