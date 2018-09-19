defmodule Talon.Plug.Theme do
  import Plug.Conn
  require Talon.Config, as: Config
  import Phoenix.Controller, only: [put_flash: 3, get_flash: 1]

  @behaviour Plug

  def init(opts) do
    Enum.into opts, %{}
  end

  def call(conn, opts) do
    talon = conn.assigns[:talon]
    new_theme = conn.params["theme"]

    # TODO: hack, add theme switching to controller
    conn =
      if new_theme do
        if (new_theme in Config.themes(:talon)) do
          Application.put_env(:admin, Admin.Admin, theme: new_theme)
          conn
        else
          Config.themes(:talon)
          # |> IO.inspect(label: "error setting theme")

          # TODO: Talon.Concern.concern(conn).messages_backend().theme_does_not_exist(theme)
          put_flash(conn, :error, "The theme \"#{new_theme}\" does not exist")
        end
        # assign conn, :params, Map.delete(conn.params, "theme")
      else
        conn
      end
    assign conn, :talon, Map.put(talon, :theme, opts[:theme] || talon.concern.theme())
  end
end
