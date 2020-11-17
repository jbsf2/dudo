defmodule DudoWeb.GameController do
  use DudoWeb, :controller

  alias DudoWeb.GameController
  alias Dudo.GameService

  plug :check_login,
       %{after_login_redirect_path: &GameController.game_path/1} when action == :show

  plug :check_login,
       %{after_login_redirect_path: &GameController.welcome_path/1}
       when action in [:create, :join]

  plug :check_game_exists when action == :show

  def create(conn, _params) do
    game_id = GameService.new_game()

    conn |> redirect(to: Routes.game_path(conn, :show, game_id))
  end

  def join(conn, %{"game" => %{"id" => game_id}}) do
    conn |> redirect(to: Routes.game_path(conn, :show, game_id))
  end

  def show(conn, _params) do
    %{path_params: %{"id" => game_id}} = conn
    player_name = get_session(conn, :player_name)

    if !GameService.player_exists?(game_id, player_name) do
      # new player; add them to the game
      GameService.add_player(game_id, player_name)

      conn
      |> put_session(:game_id, game_id)
      |> redirect(to: Routes.live_path(conn, DudoWeb.GameLive, game_id))
    else
      if game_id == get_session(conn, :game_id) do
        # returning player; admit them to the game
        conn |> redirect(to: Routes.live_path(conn, DudoWeb.GameLive, game_id))
      else
        # player name collision; direct player to provide a different name
        conn
        |> put_flash(
          :info,
          "There is already a player named #{player_name}. Would you like to join with a different name?"
        )
        |> put_session(:after_login_redirect_path, Routes.game_path(conn, :show, game_id))
        |> redirect(to: Routes.login_path(conn, :new))
      end
    end
  end

  def check_login(conn, opts) do
    if get_session(conn, :player_name) == nil do
      conn
      |> put_flash(:info, "Enter your name to join the game!")
      |> put_session(:after_login_redirect_path, opts.after_login_redirect_path.(conn))
      |> redirect(to: Routes.login_path(conn, :new))
      |> halt
    else
      conn
    end
  end

  def check_game_exists(conn, _opts) do
    %{path_params: %{"id" => game_id}} = conn

    if !GameService.exists?(game_id) do
      conn
      |> delete_session(:game_id)
      |> put_flash(
        :info,
        "Oops! Looks like that game is over. Join a different one or start a new one."
      )
      |> redirect(to: welcome_path(conn))
      |> halt
    else
      conn
    end
  end

  def welcome_path(conn) do
    Routes.welcome_path(conn, :show)
  end

  def game_path(conn) do
    %{path_params: %{"id" => game_id}} = conn
    Routes.game_path(conn, :show, game_id)
  end
end
