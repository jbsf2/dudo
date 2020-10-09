defmodule DudoWeb.GameControllerTest do
  use DudoWeb.ConnCase

  test "POST /create when logged in", %{conn: conn} do
    conn = Plug.Test.init_test_session(conn, player_name: "Player 1")
    conn = post(conn, Routes.game_path(conn, :create))

    game_id = Plug.Conn.get_session(conn, "game_id")

    assert redirected_to(conn, 302) == Routes.game_path(conn, :show, game_id)
  end

end
