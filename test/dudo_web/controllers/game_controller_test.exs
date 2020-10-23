defmodule DudoWeb.GameControllerTest do
  use DudoWeb.ConnCase

  alias Dudo.GameService

  test "POST /create when logged in", %{conn: conn} do
    conn = Plug.Test.init_test_session(conn, player_name: "Player 1")
    conn = post(conn, Routes.game_path(conn, :create))

    game_id = Plug.Conn.get_session(conn, "game_id")

    assert redirected_to(conn, 302) == Routes.live_path(conn, DudoWeb.GameLive, game_id)
  end

  test "POST /join when logged in", %{conn: conn} do
    game_id = GameService.new_game("Player 1")

    conn =
      conn
      |> Plug.Test.init_test_session(player_name: "Player 2")
      |> post(Routes.game_path(conn, :join, %{"game" => %{"id" => game_id}}))

    assert redirected_to(conn, 302) == Routes.live_path(conn, DudoWeb.GameLive, game_id)
  end
end
