defmodule TalonTest.DashboardTest do
  use TestTalon.ConnCase
  require Logger

  test "GET /talon", %{conn: conn} do
    conn = get conn, "/talon"
    assert html_response(conn, 200) =~ "Test Layout"
    assert html_response(conn, 200) =~ "Test Dashboard"
  end

  test "GET /talon/pages/dashboard", %{conn: conn} do
    conn = get conn, "/talon/pages/dashboard"
    assert html_response(conn, 200) =~ "Test Layout"
    assert html_response(conn, 200) =~ "Test Dashboard"
  end
end
