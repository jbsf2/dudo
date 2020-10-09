defmodule DudoWeb.LoginControllerTest do
  use DudoWeb.ConnCase

  test "GET /login", %{conn: conn} do
    conn = get(conn, "/login")

    assert html_response(conn, 200) =~ "What's your name?"
  end

  describe "post login" do

    test "when successful, sets the player session data and redirects", %{conn: conn} do
      conn = post(conn, "/login", post: %{player_name: "Player 1"})

      player_name = Plug.Conn.get_session(conn, "player_name")

      assert player_name == "Player 1"
      assert redirected_to(conn, 302) == "/welcome"
    end

  end
end
