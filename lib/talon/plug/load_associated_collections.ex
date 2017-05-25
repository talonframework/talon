defmodule Talon.Plug.LoadAssociatedCollections do
  @moduledoc """
  Fetch associated collections for a given model

  ## Examples

      iex> plug Talon.Plug.LoadAssociaedCollections
  """

  import Plug.Conn

  @behaviour Plug

  @dialyzer [
    {:nowarn_function, call: 2},
    {:nowarn_function, init: 1},
  ]

  @spec init(Keyword.t) :: Map.t
  def init(opts) do
    # unless opts[:repo] do
    #   raise "must provide the repo option"
    # end
    Enum.into(opts, %{})
  end

  @spec call(Plug.Conn.t, Map.t) :: Plug.Conn.t
  def call(conn, opts) do
    talon = conn.assigns[:talon] || %{}
    repo = opts[:repo] || talon[:repo] || raise("repo required")
    assigns_key = opts[:resource_assigns_key] || :resource
    # require IEx
    # IEx.pry
    case conn.assigns[assigns_key] do
      nil ->
        conn
      resource ->
        assocs = get_associations(resource, repo)
        talon = conn.assigns[:talon] || %{}
        assign conn, :talon, Map.put(talon, :associations, assocs)
    end
  end

  # TODO: This needs to be abstraced from ecto
  defp get_associations(struct, repo) when is_map(struct) do
    get_associations struct.__struct__, repo
  end
  defp get_associations(module, repo) do
    :associations
    |> module.__schema__
    |> Enum.map(fn field ->
      case module.__schema__(:association, field) do
        %Ecto.Association.BelongsTo{owner_key: owner_key} = assoc ->
          {owner_key, repo.all(assoc.queryable)}
        # TODO: What about many to many and has_many through?
        # %Ecto.Association.Has{field: field} = assoc ->
        #   {field, assoc}
        _ -> []
      end
    end)
  end
end
