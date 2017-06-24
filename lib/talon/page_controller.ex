defmodule Talon.PageController do
 defmacro __using__(opts) do
    quote do
      opts = unquote(opts)
      talon = opts[:concern] || raise("concern option required")
      plug :set_concern, talon: talon


      @spec index(Plug.Conn.t, Map.t) :: Plug.Conn.t
      def index(conn, params) do
        page = default_page(conn)
        render(conn, "#{page}.html") # TODO: use index template (DJS)
      end

      @spec show(Plug.Conn.t, Map.t) :: Plug.Conn.t
      def show(conn, params) do
        page = Map.get(params, "page", default_page(conn))
        render(conn, "#{page}.html") # TODO: use show template
      end

      @spec default_page(Plug.Conn.t) :: String.t
      def default_page(conn) do
        conn.assigns.talon.concern.dashboard_name()
      end

      @spec set_concern(Plug.Conn.t, Keyword.t) :: Plug.Conn.t
      defp set_concern(conn, opts) do
        assign conn, :talon, Enum.into(opts, %{})
      end

      defoverridable [index: 2, show: 2, default_page: 1]
    end
  end
end
