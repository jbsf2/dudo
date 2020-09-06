defmodule Dudo.PlayersTest do
  use Dudo.DataCase, async: true

  alias Dudo.Players

  test "create_player creates a player" do
    {:ok, player} = %{name: "Player 1"} |> Players.create_player()

    assert player.name == "Player 1"
  end

  test "get_player finds an existing player" do
    {:ok, player} = %{name: "Player 1"} |> Players.create_player()

    fetched_player = Players.get_player(player.id)

    assert fetched_player.id == player.id
    assert fetched_player.name == player.name

  end

#  test "create_user! creates a user" do
#    user = Test.Fixtures.user_attrs("alice") |> Accounts.create_user!()
#
#    assert user.tid == "alice"
#    assert user.username == "alice"
#  end
end
