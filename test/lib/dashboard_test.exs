defmodule TalonTest.DashboardTest do
  use TestTalon.ConnCase
  require Logger

  test "GET /talon/dashboard",  %{conn: conn} do
    conn = get conn, "/talon/dashboard"
    assert html_response(conn, 200) =~ "Test Layout"
    assert html_response(conn, 200) =~ "Test Dashboard"
  end

  test "GET /talon", %{conn: conn} do
    conn = get conn, "/talon"
    assert html_response(conn, 200) =~ "Test Layout"
    assert html_response(conn, 200) =~ "Test Dashboard"
  end
end
