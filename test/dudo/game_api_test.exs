defmodule Dudo.GameApiTest do
  use ExUnit.Case

  alias Dudo.GameApi

  test "adding a player" do
    pid = GameApi.start()
    GameApi.add_player(pid, "Bob")
    game = GameApi.state(pid)
    player = hd(game.players)
    assert player.name == "Bob"
  end

  test "losing a dice" do
    pid = GameApi.start()
    GameApi.add_player(pid, "Bob")
    GameApi.add_player(pid, "Alice")
    GameApi.lose_dice(pid, "Bob")

    game = GameApi.state(pid)
    bob = Enum.find(game.players, fn player -> player.name == "Bob" end)
    assert length(bob.dice) == 4
  end

  test "querying state doesn't lose state" do
    pid = GameApi.start()
    GameApi.add_player(pid, "Bob")
    GameApi.add_player(pid, "Alice")

    game = GameApi.state(pid)
    assert length(game.players) == 2

    GameApi.add_player(pid, "Jane")
    game = GameApi.state(pid)
    assert length(game.players) == 3
  end
end
