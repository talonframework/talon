defmodule ExAdmin.Controller do

  defmacro __using__(:resource) do
    quote do
    end
  end

  defmacro __using__(opts) do
    quote do
      opts = unquote(opts)
      repo = opts[:repo]   || raise("repo option required")
      admin = opts[:admin] || raise("admin option required")
      plug :set_repo, repo: repo, admin: admin

      # TODO: Add docs for each of these and indicate they are overridable

      def set_repo(conn, opts) do
        assign conn, :ex_admin, Enum.into(opts, %{})
      end

      def index(conn, _params) do
        render(conn, "index.html")
      end

      def new(conn, _params) do
        ex_admin = conn.assigns.ex_admin
        changeset = ex_admin.admin_resource.schema.changeset(conn.assigns.resource)
        render(conn, "new.html", changeset: changeset)
      end

      def show(conn, _params) do
        render conn, "show.html"
      end

      def edit(conn, params) do
        changeset = conn.assigns.ex_admin.schema.changeset(conn.assigns.resource)
        render conn, "edit.html", changeset: changeset
      end

      def create(conn, params) do
        # IO.inspect params, label: "params: "
        params_key = ExAdmin.View.params_key(conn)
        # IO.inspect params_key, label: "params_key"
        repo = ExAdmin.View.repo(conn)
        changeset = conn.assigns.ex_admin.schema.changeset(conn.assigns.resource, params[params_key])
        # TODO: we should use a context here. Can you use the user's context? How can be know what API they
        #       are exposiing.
        case repo.insert(changeset) do
          {:ok, resource} ->
            redirect conn, to: ExAdmin.Utils.admin_resource_path(resource, :show)
          {:error, changeset} ->
            render conn, "new.html", changeset: changeset
        end
      end

      def update(conn, params) do
        params_key = ExAdmin.View.params_key(conn)
        repo = ExAdmin.View.repo(conn)
        changeset = conn.assigns.ex_admin.schema.changeset(conn.assigns.resource, params[params_key])
        case repo.insert(changeset) do
          {:ok, resource} ->
            redirect conn, to: ExAdmin.Utils.admin_resource_path(resource, :show)
          {:error, changeset} ->
            render conn, "edit.html", changeset: changeset
        end
      end

      def delete(conn, params) do
        repo = ExAdmin.View.repo(conn)
        repo.delete! conn.assigns.resource
        redirect conn, "index.html"
      end

      defoverridable [index: 2, show: 2, new: 2, edit: 2, create: 2, update: 2, delete: 2, set_repo: 2]
    end
  end

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
