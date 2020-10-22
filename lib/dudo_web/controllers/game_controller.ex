defmodule DudoWeb.GameController do
  use DudoWeb, :controller

  plug :check_login when action in [:show]

  alias Dudo.GameService

  def create(conn, _) do
    player_name = get_session(conn, :player_name)

    {:ok, game_id} = GameService.start_link(player_name)

    conn
    |> put_session(:game_id, game_id)
    |> redirect(to: Routes.game_path(conn, :show, game_id))
  end

  def show(conn, %{"id" => game_id}) do
    player_name = get_session(conn, :player_name)
    players = GameService.state(game_id).players
    render(conn, "show.html", players: players, current_player: player_name, game_id: game_id)
  end

  def join(conn, %{"game" => %{"id" => game_id}}) do
    GameService.add_player(game_id, get_session(conn, :player_name))

    conn
    |> put_session(:game_id, game_id)
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
