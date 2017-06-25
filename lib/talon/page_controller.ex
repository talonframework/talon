defmodule Talon.PageController do
 defmacro __using__(opts) do
    quote do
      opts = unquote(opts)
      talon = opts[:concern] || raise("concern option required")
      plug :set_concern, talon: talon


      @spec index(Plug.Conn.t, Map.t) :: Plug.Conn.t
      def index(conn, params) do
        render(conn, "index.html")
      end

      @spec set_concern(Plug.Conn.t, Keyword.t) :: Plug.Conn.t
      defp set_concern(conn, opts) do
        assign conn, :talon, Enum.into(opts, %{})
      end

      defoverridable [index: 2]
    end
  end
end
