defmodule DudoWeb.LoginController do
  use DudoWeb, :controller

  alias Dudo.Games

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"post" => %{"player_name" => player_name}}) do
    {:ok, player} = %{name: player_name} |> Games.create_player()

    conn
    |> put_session(:player_id, player.id)
    |> put_session(:player_name, player.name)
    |> redirect(to: "/welcome")
  end
end