defmodule TalonTest.DashboardTest do
  use TestTalon.ConnCase
  require Logger

  test "GET /admin", %{conn: conn} do
    conn = get conn, "/admin"
    assert html_response(conn, 200) =~ "Test Layout"
    assert html_response(conn, 200) =~ "Test Dashboard"
  end

  test "GET /admin/pages/dashboard", %{conn: conn} do
    conn = get conn, "/admin/pages/dashboard"
    assert html_response(conn, 200) =~ "Test Layout"
    assert html_response(conn, 200) =~ "Test Dashboard"
  end
end
