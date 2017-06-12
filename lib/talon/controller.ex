defmodule Talon.Controller do # TODO: rename to ResourceController (DJS)

  defmacro __using__(opts) do
    quote do
      opts = unquote(opts)
      repo = opts[:repo] || raise("repo option required")
      talon = opts[:context] || raise("context option required")
      plug :set_repo, repo: repo, talon: talon

      # TODO: Add docs for each of these and indicate they are overridable

      @spec set_repo(Plug.Conn.t, Keyword.t) :: Plug.Conn.t
      def set_repo(conn, opts) do
        assign conn, :talon, Enum.into(opts, %{})
      end

      @spec index(Plug.Conn.t, Map.t) :: Plug.Conn.t
      def index(conn, _params) do
        render(conn, "index.html")
      end

      @spec new(Plug.Conn.t, Map.t) :: Plug.Conn.t
      def new(conn, _params) do
        talon = conn.assigns.talon
        changeset = talon.talon_resource.schema.changeset(conn.assigns.resource, %{})
        render(conn, "new.html", changeset: changeset)
      end

      @spec show(Plug.Conn.t, Map.t) :: Plug.Conn.t
      def show(conn, _params) do
        render conn, "show.html"
      end

      @spec edit(Plug.Conn.t, Map.t) :: Plug.Conn.t
      def edit(conn, params) do
        changeset = conn.assigns.talon.schema.changeset(conn.assigns.resource, %{})
        render conn, "edit.html", changeset: changeset
      end

      @spec create(Plug.Conn.t, Map.t) :: Plug.Conn.t
      def create(conn, params) do
        # IO.inspect params, label: "params: "
        params_key = Talon.View.params_key(conn)
        # IO.inspect params_key, label: "params_key"
        repo = Talon.View.repo(conn)
        changeset = conn.assigns.talon.schema.changeset(conn.assigns.resource, params[params_key])
        # TODO: we should use a context here. Can you use the user's context? How can be know what API they
        #       are exposiing.
        case repo.insert(changeset) do
          {:ok, resource} ->
            redirect conn, to: Talon.Utils.talon_resource_path(resource, :show)
          {:error, changeset} ->
            render conn, "new.html", changeset: changeset
        end
      end

      @spec update(Plug.Conn.t, Map.t) :: Plug.Conn.t
      def update(conn, params) do
        params_key = Talon.View.params_key(conn)
        repo = Talon.View.repo(conn)
        changeset = conn.assigns.talon.schema.changeset(conn.assigns.resource, params[params_key])
        case repo.insert(changeset) do
          {:ok, resource} ->
            redirect conn, to: Talon.Utils.talon_resource_path(resource, :show)
          {:error, changeset} ->
            render conn, "edit.html", changeset: changeset
        end
      end

      @spec delete(Plug.Conn.t, Map.t) :: Plug.Conn.t
      def delete(conn, params) do
        repo = Talon.View.repo(conn)
        repo.delete! conn.assigns.resource
        redirect conn, to: Talon.Utils.talon_resource_path(conn.assigns.resource.__struct__, :index)
      end

      @spec search(Plug.Conn.t, Map.t) :: Plug.Conn.t
      def search(conn, params) do
        theme_module = Talon.View.theme_module(conn)
        conn
        |> put_layout(false)
        |> put_view(Module.concat([theme_module, Application.get_env(:talon, :web_namespace), DatatableView]))
        |> render("search.html", conn: conn)
      end

      defoverridable [index: 2, show: 2, new: 2, edit: 2, create: 2, update: 2, delete: 2, set_repo: 2, search: 2]
    end
  end

  @spec talon_resource_schema(String.t | Struct.t) :: {Struct.t, atom}
  def talon_resource_schema(resource) when is_binary(resource) do
    talon_resource_schema String.to_atom(resource)
  end
  def talon_resource_schema(resource) do
    module =
      :talon
      |> Application.get_env(:resources, [])
      |> Keyword.get(resource, [])
    {resource, module}
  end
end
