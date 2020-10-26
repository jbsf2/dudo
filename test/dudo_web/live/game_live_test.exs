defmodule DudoWeb.GameLiveTest do
  use DudoWeb.ConnCase, async: true

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  import SweetXml

  setup do
    conn = Phoenix.ConnTest.build_conn()
    create_path = Routes.game_path(conn, :create)

    conn =
      conn
      |> Plug.Test.init_test_session(player_name: "Player 1")
      |> post(create_path)

    game_path = redirected_to(conn, 302)

    {:ok, conn: conn, game_path: game_path}
  end

  test "disconnected and connected mount", %{conn: conn, game_path: game_path} do
    conn = get(conn, game_path)
    assert html_response(conn, 200)
    {:ok, _view, _html} = live(conn)
  end

  test "redirected mount", %{conn: conn, game_path: game_path} do
    {:ok, _view, html} = live(conn, game_path)
    assert html =~ "<td class=\"player-name\">Player 1</td>"
  end

  test "losing and adding dice", %{conn: conn, game_path: game_path} do
    {:ok, view, html} = live(conn, game_path)
    assert dice_count(html) == 5

    html = render_submit(view, "lose_dice")
    assert dice_count(html) == 4

    html = render_submit(view, "add_dice")
    assert dice_count(html) == 5
  end

  test "redirect to login when user not logged in" do
    conn = Phoenix.ConnTest.build_conn()
    game_path = Routes.live_path(conn, DudoWeb.GameLive, "test_id")
    conn = conn |> get(game_path)

    assert redirected_to(conn, 302) == Routes.login_path(conn, :new)
  end

  test "updating the other players when a player changes the game state", %{
    conn: conn1,
    game_path: game_path
  } do
    # step 1: have a second player join the game
    # game_path will look like "/games/ABCD"
    game_id = String.slice(game_path, 7..11)
    conn2 = Phoenix.ConnTest.build_conn()

    conn2 =
      conn2
      |> Plug.Test.init_test_session(player_name: "Player 2")
      |> post(Routes.game_path(conn2, :join), %{"game" => %{"id" => game_id}})

    assert redirected_to(conn2, 302) == Routes.live_path(conn2, DudoWeb.GameLive, game_id)

    # step 2: connect both players via LiveView, make sure they have expected dice count
    {:ok, view1, html1} = live(conn1, game_path)
    assert dice_count(html1) == 10

    {:ok, view2, html2} = live(conn2, game_path)
    assert dice_count(html2) == 10

    # step 3: lose dice for Player 1
    html1 = render_submit(view1, :lose_dice)
    assert dice_count(html1) == 9

    # step 4: assert view for Player 2 is updated
    # TODO: make this async-safe
    # ask Greg - is this in fact async-safe already?
    html2 = render(view2)
    assert dice_count(html2) == 9
  end

  defp dice_count(html) do
    html |> xpath(~x"count(//li[contains(@class, 'dice')])")
  end
end
