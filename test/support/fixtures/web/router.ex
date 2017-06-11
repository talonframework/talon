defmodule TestTalon.Router do
  use Phoenix.Router
  use Talon.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/talon", TestTalon do
    pipe_through :browser
    talon_routes()
  end
end
