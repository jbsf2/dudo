defmodule DudoWeb.GameController do
  use DudoWeb, :controller

  plug :check_login when action in [:show]

  alias Dudo.GameService

  def create(conn, _) do
    player_name = get_session(conn, :player_name)

    game_id = GameService.create_game(player_name)
    conn
    |> put_session(:game_id, game_id)
    |> redirect(to: Routes.game_path(conn, :show, game_id))
  end

  def show(conn, %{"id" => game_id}) do
    player_name = get_session(conn, :player_name)
    {current_player, other_players} = GameService.state_for_player(game_id, player_name)
    render(conn, "show.html", current_player: current_player, other_players: other_players)
  end

  def join(conn, %{"game" => %{"id" => game_id}}) do
    redirect(conn, to: Routes.game_path(conn, :show, game_id))
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
