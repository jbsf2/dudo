defmodule DudoWeb.DiceController do
  use DudoWeb, :controller

  plug :check_login

  alias Dudo.GameService

  def create(conn, _) do
    player_name = get_session(conn, :player_name)
    game_id = get_session(conn, :game_id)
    GameService.add_dice(game_id, player_name)

    conn
    |> redirect(to: Routes.game_path(conn, :show, game_id))  end

  def delete(conn, _) do
    player_name = get_session(conn, :player_name)
    game_id = get_session(conn, :game_id)
    GameService.lose_dice(game_id, player_name)

    conn
    |> redirect(to: Routes.game_path(conn, :show, game_id))
  end

  def check_login(conn, _opts) do
    if get_session(conn, :player_name) == nil do
      conn
      |> put_flash(:info, "Enter your name to join the game!")
      |> put_session(:after_login_redirect_path, conn.request_path)
      |> redirect(to: Routes.login_path(conn, :new))
      |> halt
    else
      conn
    end
  end
end
