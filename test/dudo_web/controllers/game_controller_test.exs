defmodule DudoWeb.GameControllerTest do
  use DudoWeb.ConnCase

  describe "POST /create" do
    test "when logged in it creates a game and redirects to the game path", %{conn: conn} do
      conn = Plug.Test.init_test_session(conn, player_name: "Player 1", player_id: 1)
      conn = post(conn, Routes.game_path(conn, :create))

      %{id: game_id} = redirected_params(conn)

      assert redirected_to(conn, 302) == Routes.game_path(conn, :show, game_id)
    end

    test "when not logged in, it redirects to login", %{conn: conn} do
      conn = post(conn, Routes.game_path(conn, :create))

      assert redirected_to(conn, 302) == Routes.login_path(conn, :new)
    end
  end

  describe "POST /join" do
    test "when logged in, it redirects to game_path", %{conn: conn} do
      conn =
        conn
        |> Plug.Test.init_test_session(player_name: "Player 1", player_id: 1)
        |> post(Routes.game_path(conn, :join, %{"game" => %{"id" => "foo"}}))

      assert redirected_to(conn, 302) == Routes.game_path(conn, :show, "foo")
    end

    test "when not logged in, it redirects to login_path", %{conn: conn} do
      conn =
        conn
        |> post(Routes.game_path(conn, :join, %{"game" => %{"id" => "foo"}}))

      assert redirected_to(conn, 302) == Routes.login_path(conn, :new)
    end
  end

  describe "GET /show" do
    # test "when logged in redirects to login", %{conn: conn} do
    #   conn = conn |> get(Routes.game_path(conn, :show, "any game id"))
    #   assert redirected_to(conn, 302) == Routes.login_path(conn, :new)
    # end

    test "when not logged in, it redirects to login", %{conn: conn} do
      conn = conn |> get(Routes.game_path(conn, :show, "any game id"))
      assert redirected_to(conn, 302) == Routes.login_path(conn, :new)
    end

    test "when the game does not exist, it redirects to welcome", %{conn: conn} do
      conn =
        conn
        |> Plug.Test.init_test_session(player_name: "Player 1", player_id: 1)
        |> get(Routes.game_path(conn, :show, "does not exist"))

      assert redirected_to(conn, 302) == Routes.welcome_path(conn, :show)
    end

    """
    if we haven't seen the player before, admit them to the game.
    set the game_id in the session, and redirect to the live view
    """
    |> test  %{conn: conn} do
      conn = conn |> Plug.Test.init_test_session(player_name: "Player 1", player_id: 1)
      conn = post(conn, Routes.game_path(conn, :create))

      %{id: game_id} = redirected_params(conn)
      conn = conn |> get(Routes.game_path(conn, :show, game_id))

      assert redirected_to(conn, 302) == Routes.live_path(conn, DudoWeb.GameLive, game_id)
    end

    """
    if there's a name collision, redirect to login and show a flash message
    """
    |> test %{conn: conn} do
      conn = conn |> Plug.Test.init_test_session(player_name: "Alice", player_id: 1)
      conn = post(conn, Routes.game_path(conn, :create))

      %{id: game_id} = redirected_params(conn)
      conn |> get(Routes.game_path(conn, :show, game_id))

      conn2 =
        Phoenix.ConnTest.build_conn()
        |> Plug.Test.init_test_session(player_name: "Alice", player_id: 2)

      conn2 = conn2 |> get(Routes.game_path(conn, :show, game_id))

      assert redirected_to(conn2, 302) == Routes.login_path(conn2, :new)
    end

    """
    if we see the same player more than once, admit them to the game
    """
    |> test %{conn: conn} do
      conn = conn |> Plug.Test.init_test_session(player_name: "Player 1", player_id: 1)
      conn = post(conn, Routes.game_path(conn, :create))

      %{id: game_id} = redirected_params(conn)
      conn |> get(Routes.game_path(conn, :show, game_id))

      conn2 =
        Phoenix.ConnTest.build_conn()
        |> Plug.Test.init_test_session(player_name: "Player 1", player_id: 1, game_id: game_id)

      conn2 = conn2 |> get(Routes.game_path(conn, :show, game_id))

      assert redirected_to(conn2, 302) == Routes.live_path(conn, DudoWeb.GameLive, game_id)
    end
  end
end
