defmodule Talon.PageController do
 defmacro __using__(opts) do
    quote do
      opts = unquote(opts)
      talon = opts[:concern] || raise("concern option required")
      plug :set_concern, talon: talon

      @spec page(Plug.Conn.t, Map.t) :: Plug.Conn.t
      def page(conn, params) do
        page = Map.get(params, "page", "dashboard")
        render(conn, "#{page}.html")
      end

      @spec set_concern(Plug.Conn.t, Keyword.t) :: Plug.Conn.t
      defp set_concern(conn, opts) do
        assign conn, :talon, Enum.into(opts, %{})
      end

      defoverridable [page: 2]
    end
  end
end
