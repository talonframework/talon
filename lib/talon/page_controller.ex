defmodule Talon.PageController do
 defmacro __using__(opts) do
    quote do
      opts = unquote(opts)
      talon = opts[:context] || raise("context option required")
      plug :set_context, talon: talon

      # TODO: Add docs for each of these and indicate they are overridable

      @spec set_context(Plug.Conn.t, Keyword.t) :: Plug.Conn.t
      def set_context(conn, opts) do
        assign conn, :talon, Enum.into(opts, %{})
      end

      @spec page(Plug.Conn.t, Map.t) :: Plug.Conn.t
      def page(conn, params) do
        page = Map.get(params, "page", "dashboard")  # TODO: don't hard code dashboard (DJS)

        # TODO: remove (DJS)

        # defn = get_registered_by_controller_route!(conn, page)
        # conn =  assign(conn, :defn, defn)

        # contents = defn.__struct__.page_view(conn)

        # render(conn, "admin.html", html: contents, resource: nil, scope_counts: [],
        #   filters: (if false in defn.index_filters, do: false, else: defn.index_filters))

        render(conn, "dashboard.html")
      end

      @spec dashboard(Plug.Conn.t, Map.t) :: Plug.Conn.t # TODO: remove and just use page? (DJS)
      def dashboard(conn, params) do
        conn =  assign(conn, :page, "dashboard") # TODO: Cheating? (DJS)
        page(conn, Map.put(params, "page", "dashboard"))
      end
    end
  end
end
