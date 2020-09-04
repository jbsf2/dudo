defmodule Dudo.PlayersTest do
  use Dudo.DataCase, async: true

  alias Dudo.Players
  alias Dudo.Test

  test "create_player creates a player" do
    {:ok, player} = %{name: "Player 1"} |> Players.create_player()

    assert player.name == "Player 1"
  end

#  test "create_user! creates a user" do
#    user = Test.Fixtures.user_attrs("alice") |> Accounts.create_user!()
#
#    assert user.tid == "alice"
#    assert user.username == "alice"
#  end
end
