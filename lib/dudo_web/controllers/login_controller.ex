defmodule DudoWeb.LoginController do
  use DudoWeb, :controller

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"login" => %{"player_name" => player_name}}) do
    player = Dudo.Player.new_player(player_name)
    redirect_path = get_session(conn, :after_login_redirect_path) || "/welcome"

    conn
    |> put_session(:player_name, player.name)
    |> delete_session(:after_login_redirect_path)
    |> redirect(to: redirect_path)
  end
end
