defmodule DudoWeb.LoginController do
  use DudoWeb, :controller

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"login" => %{"player_name" => player_name}}) do
    player = Dudo.Player.new_player(player_name)

    conn
    |> put_session(:player_name, player.name)
    |> redirect(to: "/welcome")
  end
end
