defmodule DudoWeb.GameLiveTest do
  use DudoWeb.ConnCase, async: true

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  import SweetXml

  setup do
    conn = Phoenix.ConnTest.build_conn()

    conn =
      conn
      |> Plug.Test.init_test_session(player_id: "Player 1", player_name: "Player 1")
      |> post(Routes.game_path(conn, :create))

    %{id: game_id} = redirected_params(conn)

    conn = conn |> get(Routes.game_path(conn, :show, game_id))

    live_path = redirected_to(conn, 302)

    {:ok, conn: conn, live_path: live_path, game_id: game_id}
  end

  describe "mount" do
    test "disconnected and connected mount", %{conn: conn, live_path: live_path} do
      conn = get(conn, live_path)
      assert html_response(conn, 200)
      {:ok, _view, _html} = live(conn)
    end

    test "redirected mount", %{conn: conn, live_path: live_path} do
      {:ok, _view, html} = live(conn, live_path)
      assert html =~ "class=\"actual-name\">Player 1<"
    end

    test "redirect when user not logged in" do
      conn = Phoenix.ConnTest.build_conn()
      live_path = Routes.live_path(conn, DudoWeb.GameLive, "test_id")
      conn = conn |> get(live_path)

      assert redirected_to(conn, 302) == Routes.game_path(conn, :show, "test_id")
    end

    test "it redirects for games that don't exist", %{conn: conn} do
      bad_path = Routes.live_path(conn, DudoWeb.GameLive, "does not exist")
      {:error, {:redirect, %{to: redirect_path}}} = live(conn, bad_path)
      assert redirect_path == Routes.game_path(conn, :show, "does not exist")
    end

    test "it redirects for games the player doesn't belong to", %{
      live_path: live_path,
      game_id: game_id
    } do

      conn =
        Phoenix.ConnTest.build_conn()
        |> Phoenix.ConnTest.init_test_session(player_id: "Player 2", player_name: "Player 2")
        |> get(live_path)

      assert redirected_to(conn, 302) == Routes.game_path(conn, :show, game_id)
    end
  end

  test "losing and adding dice", %{conn: conn, live_path: live_path} do
    {:ok, view, html} = live(conn, live_path)
    assert dice_count(html) == 5

    html = render_submit(view, "lose_dice")
    assert dice_count(html) == 4

    html = render_submit(view, "add_dice")
    assert dice_count(html) == 5
  end

  test "start new game", %{conn: conn, live_path: live_path} do
    {:ok, view, html} = live(conn, live_path)
    assert invitation_link_present?(html) == false
    html = render_submit(view, "start_new_game")
    assert invitation_link_present?(html) == true
  end

  test "updating the other players when a player changes the game state", %{
    conn: conn1,
    live_path: live_path,
    game_id: game_id
  } do
    # step 1: have a second player join the game
    conn2 = Phoenix.ConnTest.build_conn()

    conn2 =
      conn2
      |> Plug.Test.init_test_session(player_id: "Player 2", player_name: "Player 2")
      |> get(Routes.game_path(conn2, :show, game_id))

    assert redirected_to(conn2, 302) == Routes.live_path(conn2, DudoWeb.GameLive, game_id)

    # step 2: connect both players via LiveView, make sure they have expected dice count
    {:ok, view1, html1} = live(conn1, live_path)
    assert dice_count(html1) == 10

    {:ok, view2, html2} = live(conn2, live_path)
    assert dice_count(html2) == 10

    # step 3: lose dice for Player 1
    html1 = render_submit(view1, :lose_dice)
    assert dice_count(html1) == 9

    # step 4: assert view for Player 2 is updated
    # TODO: is this async-safe?
    assert render(view2) |> dice_count() == 9
  end

  test "other players can see dice after show", %{
    conn: conn1,
    live_path: live_path,
    game_id: game_id
  } do

    conn2 = Phoenix.ConnTest.build_conn()

    conn2 =
      conn2
      |> Plug.Test.init_test_session(player_id: "Player 2", player_name: "Player 2")
      |> get(Routes.game_path(conn2, :show, game_id))

    # step 2: connect both players via LiveView, make sure they have expected dice count
    {:ok, view1, html1} = live(conn1, live_path)
    assert visible_dice_count(html1) == 0

    {:ok, view2, html2} = live(conn2, live_path)
    assert visible_dice_count(html2) == 0

    # Player 1 shows their dice
    html1 = render_submit(view1, :show_dice)
    assert visible_dice_count(html1) == 0
    assert render(view2) |> visible_dice_count() == 5

    # Player 1 sees their dice
    html1 = render_submit(view1, :see_dice)
    assert visible_dice_count(html1) == 5
    assert render(view2) |> visible_dice_count() == 5
  end

  defp dice_count(html) do
    html |> xpath(~x"count(//li[contains(@class, 'dice')])")
  end

  defp visible_dice_count(html) do
    html |> xpath(~x"count(//li[contains(@class, 'dice')][not(contains(@class, 'hidden'))])")
  end

  defp invitation_link_present?(html) do
    html |> xpath(~x"count(//a[@id='new_game_link'])") > 0
  end
end
