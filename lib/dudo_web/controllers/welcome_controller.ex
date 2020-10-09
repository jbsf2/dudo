defmodule DudoWeb.WelcomeController do
  use DudoWeb, :controller

  alias Dudo.Games

  def show(conn, _params) do
    player_name = get_session(conn, :player_name)
    render(conn, "show.html", player_name: player_name)
  end
end
