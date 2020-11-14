defmodule DudoWeb.GameControllerTest do
  use DudoWeb.ConnCase

  test "POST /create not logged in", %{conn: conn} do
    conn = Plug.Test.init_test_session(conn, player_name: "Player 1")
    conn = post(conn, Routes.game_path(conn, :create))

    game_id = Plug.Conn.get_session(conn, "game_id")

    assert redirected_to(conn, 302) == Routes.live_path(conn, DudoWeb.GameLive, game_id)
  end

  test "POST /join when logged in", %{conn: conn} do
    # step 1: create the game and add Player 1
    conn = Plug.Test.init_test_session(conn, player_name: "Player 1")
    conn = post(conn, Routes.game_path(conn, :create))

    game_id = Plug.Conn.get_session(conn, "game_id")

    # step 2: have a second player join the game and ensure they get redirected
    conn2 = Phoenix.ConnTest.build_conn()

    conn2 =
      conn2
      |> Plug.Test.init_test_session(player_name: "Player 2")
      |> post(Routes.game_path(conn2, :join, %{"game" => %{"id" => game_id}}))

    assert redirected_to(conn2, 302) == Routes.live_path(conn2, DudoWeb.GameLive, game_id)
  end

  test "POST /join to a game that doesn't exist", %{conn: conn} do
    # step 1: create the game and add Player 1
    conn =
      conn
      |> Plug.Test.init_test_session(player_name: "Player 1")
      |> post(Routes.game_path(conn, :join, %{"game" => %{"id" => "does not exist"}}))

    assert redirected_to(conn, 302) == Routes.login_path(conn, :new)
  end
end
