defmodule DudoWeb.GameController do
  use DudoWeb, :controller

  alias Dudo.GameService

  plug :check_login

  def create(conn, _params) do
    player_name = get_session(conn, :player_name)

    game_id = GameService.new_game(player_name)

    conn
    |> put_session(:game_id, game_id)
    |> redirect(to: Routes.live_path(conn, DudoWeb.GameLive, game_id))
  end

  def join(conn, %{"game" => %{"id" => game_id}}) do
    GameService.add_player(game_id, get_session(conn, :player_name))

    conn
    |> put_session(:game_id, game_id)
    |> redirect(to: Routes.live_path(conn, DudoWeb.GameLive, game_id))
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
