defmodule ExAdmin.Schema.Adapters do

  @type module_or_query :: map | struct | map

  @doc """
  Retrieve the primay key of a query, schema module, or a schema struct.
  
  ## Examples

      iex> primary_key from b in Blog
      :id
      iex> primary_key Blog
      :id
      iex> primary_key %Blog{}
      :id
  """
  @callback primary_key(query_or_module_or_resource :: module_or_query) :: atom

  @doc """
  Retrieve the id value of a schema struct.

      iex> get_id %Tag{name: "elixir"}
      "elixir"
  """
  @callback get_id(resource :: map | struct) :: any

  @doc """
  Retrive type of a schem field.

  ## Examples

      iex> type((from u in User), :email)
      :string

      iex> type(User, :id)
      :binary_id

      iex> type(%User{}, :login_count)
      :integer
      
  """
  @callback type(query_or_module_resource :: module_or_query, key :: atom) :: atom

  @doc """
  TBD  
  """
  @callback get_intersection_keys(reosurce :: map | struct, assoc_name :: atom) :: [resource_key: atom, assoc_key: atom]
  
end