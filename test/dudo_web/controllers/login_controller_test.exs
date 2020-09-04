defmodule DudoWeb.LoginControllerTest do
  use DudoWeb.ConnCase

  test "GET /login", %{conn: conn} do
    conn = get(conn, "/login")
    assert html_response(conn, 200) =~ "What's your name?"
  end

  test "POST /login", %{conn: conn} do
    conn = post(conn, "/login")
    assert html_response(conn, 200)
  end
end