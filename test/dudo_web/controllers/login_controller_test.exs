defmodule DudoWeb.LoginControllerTest do
  use DudoWeb.ConnCase

  test "GET /login", %{conn: conn} do
    conn = get(conn, "/login")

    assert html_response(conn, 200) =~ "What's your name?"
  end

  describe "post login" do
    test "when successful, sets the player session data and redirects", %{conn: conn} do
      conn = post(conn, "/login", login: %{player_name: "Player 1"})

      player_name = Plug.Conn.get_session(conn, "player_name")
      player_id = Plug.Conn.get_session(conn, "player_id")

      assert player_name == "Player 1"
      assert player_id != nil

      assert redirected_to(conn, 302) == "/welcome"
    end

    test "when :after_login_redirect_path is present, redirect to that path", %{conn: conn} do
      conn =
        conn
        |> Plug.Test.init_test_session(after_login_redirect_path: "/redirect_path")
        |> post("/login", login: %{player_name: "Player 1"})

      assert redirected_to(conn, 302) == "/redirect_path"
      assert get_session(conn, :after_login_redirect_path) == nil
    end
  end
end
