defmodule ExAdmin.Controller do

  defmacro __using__(:resource) do
    quote do
      def preload(resource, _action) do
        resource
      end
      defoverridable [preload: 2]
    end
  end

  defmacro __using__(opts) do
    quote do
      opts = unquote(opts)
      repo = opts[:repo]   || raise("repo option required")
      admin = opts[:admin] || raise("admin option required")
      plug :set_repo, repo: repo, admin: admin

      def set_repo(conn, opts) do
        assign conn, :ex_admin, Enum.into(opts, %{})
      end

      def index(conn, _params) do
        render(conn, "index.html")
      end
      def new(conn, _params) do
        changeset = conn.assigns.schema.changeset(conn.assigns.resource)
        render(conn, "new.html", changeset: changeset)
      end
      def edit(conn, params) do
        # resource_name = conn.
        # changeset = conn.assigns.schema.changeset(conn.assigns.resource, params[])
      end
      def create(conn, params) do

      end
      def update(conn, params) do
      end
      def delete(conn, params) do

      end
      defoverridable [index: 2, new: 2, edit: 2, create: 2, update: 2, delete: 2, set_repo: 2]
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