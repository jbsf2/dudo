defmodule DudoWeb.GameController do
  use DudoWeb, :controller

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
end
