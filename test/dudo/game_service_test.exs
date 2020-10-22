defmodule Dudo.GameServiceTest do
  use ExUnit.Case

  alias Dudo.GameService

  test "adding a player" do
    {:ok, pid} = GameService.start_link("Bob")
    game = GameService.state(pid)
    player = hd(game.players)
    assert player.name == "Bob"
  end

  test "losing and adding dice" do
    {:ok, pid} = GameService.start_link("Bob")
    GameService.add_player(pid, "Alice")
    GameService.lose_dice(pid, "Bob")

    game = GameService.state(pid)
    bob = Enum.find(game.players, fn player -> player.name == "Bob" end)
    assert length(bob.dice) == 4

    GameService.add_dice(pid, "Bob")

    game = GameService.state(pid)
    bob = Enum.find(game.players, fn player -> player.name == "Bob" end)
    assert length(bob.dice) == 5
  end

  test "querying state doesn't lose state" do
    {:ok, pid} = GameService.start_link("Bob")
    GameService.add_player(pid, "Alice")

    game = GameService.state(pid)
    assert length(game.players) == 2

    GameService.add_player(pid, "Jane")
    game = GameService.state(pid)
    assert length(game.players) == 3
  end

  test "create_game starts a game and adds a player" do
    {:ok, pid} = GameService.start_link("Player 1")
    game = GameService.state(pid)
    assert hd(game.players).name == "Player 1"
  end
end
