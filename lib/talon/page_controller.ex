defmodule Talon.PageController do
 defmacro __using__(opts) do
    quote do
      opts = unquote(opts)
      talon = opts[:context] || raise("context option required")
      plug :set_context, talon: talon

      @spec page(Plug.Conn.t, Map.t) :: Plug.Conn.t
      def page(conn, params) do
        page = Map.get(params, "page", "dashboard")
        render(conn, "#{page}.html")
      end

      @spec set_context(Plug.Conn.t, Keyword.t) :: Plug.Conn.t
      defp set_context(conn, opts) do
        assign conn, :talon, Enum.into(opts, %{})
      end
    end
  end
end
