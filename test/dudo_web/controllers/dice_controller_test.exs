defmodule DudoWeb.DiceControllerTest do
  use DudoWeb.ConnCase

  test "creating", %{conn: conn} do
    conn = Plug.Test.init_test_session(conn, player_name: "Player 1")
    conn = post(conn, Routes.game_path(conn, :create))

    game_id = Plug.Conn.get_session(conn, "game_id")

    conn = post(conn, Routes.dice_path(conn, :create, game_id, "Player 1"))

    assert redirected_to(conn, 302) == Routes.game_path(conn, :show, game_id)
  end

  test "deleting", %{conn: conn} do
    conn = Plug.Test.init_test_session(conn, player_name: "Player 1")
    conn = post(conn, Routes.game_path(conn, :create))

    game_id = Plug.Conn.get_session(conn, "game_id")

    conn = post(conn, Routes.dice_path(conn, :delete, game_id, "Player 1"))

    assert redirected_to(conn, 302) == Routes.game_path(conn, :show, game_id)
  end
end
