defmodule DudoWeb.GameController do
  use DudoWeb, :controller

  alias Dudo.GameApi

  def create(conn, _) do
    player_name = get_session(conn, :player_name)

    pid = GameApi.create_game(player_name)

    conn
    |> put_session(:game_id, pid)
    |> redirect(to: Routes.game_path(conn, :show, pid))
  end
end
