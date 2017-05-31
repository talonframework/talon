defmodule TalonTest.DashboardTest do
  use TestTalon.ConnCase
  require Logger

  test "get dashboard",  %{conn: conn} do
    conn = get conn, "/talon/dashboard"
    assert html_response(conn, 200) =~ "Dashboard"
  end

  test "get talon retrieves dashboard", %{conn: conn} do
    onn = get conn, "/talon"
    assert html_response(conn, 200) =~ "Dashboard"
  end

  test "dashboard shows sidebar" do
    conn = get build_conn(), "/talon"
    assert html_response(conn, 200) =~ "Dashboard"
    assert String.contains?(conn.resp_body, "Test Sidebar")
    assert String.contains?(conn.resp_body, "This is a test.")
  end
end
