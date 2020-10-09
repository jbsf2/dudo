defmodule DudoWeb.WelcomeControllerTest do
  use DudoWeb.ConnCase

  test "GET /welcome", %{conn: conn} do
    conn = Plug.Test.init_test_session(conn, player_name: "Player 1")
    conn = get(conn, "/welcome")

    assert html_response(conn, 200) =~ "Welcome, Player 1!"
  end

end