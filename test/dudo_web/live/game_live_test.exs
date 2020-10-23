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

    html = render_submit(view, :lose_dice)
    assert dice_count(html) == 4

    html = render_submit(view, :add_dice)
    assert dice_count(html) == 5
  end

  test "redirect to login when user not logged in" do
    conn = Phoenix.ConnTest.build_conn()
    game_path = Routes.live_path(conn, DudoWeb.GameLive, "test_id")
    conn = conn |> get(game_path)

    assert redirected_to(conn, 302) == Routes.login_path(conn, :new)
  end

  defp dice_count(html) do
    html |> xpath(~x"count(//li[contains(@class, 'dice')])")
  end
end
