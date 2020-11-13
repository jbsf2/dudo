defmodule Dudo.GameServiceTest do
  use ExUnit.Case

  alias Dudo.GameService

  test "adding a player" do
    game_id = GameService.new_game("Bob")
    game = GameService.state(game_id)
    player = hd(game.players)
    assert player.name == "Bob"
  end

  test "losing and adding dice" do
    game_id = GameService.new_game("Bob")
    GameService.add_player(game_id, "Alice")
    GameService.lose_dice(game_id, "Bob")

    game = GameService.state(game_id)
    bob = Enum.find(game.players, fn player -> player.name == "Bob" end)
    assert length(bob.dice) == 4

    GameService.add_dice(game_id, "Bob")

    game = GameService.state(game_id)
    bob = Enum.find(game.players, fn player -> player.name == "Bob" end)
    assert length(bob.dice) == 5
  end

  test "querying state doesn't lose state" do
    game_id = GameService.new_game("Bob")
    GameService.add_player(game_id, "Alice")

    game = GameService.state(game_id)
    assert length(game.players) == 2

    GameService.add_player(game_id, "Jane")
    game = GameService.state(game_id)
    assert length(game.players) == 3
  end

  test "create_game starts a game and adds a player" do
    game_id = GameService.new_game("Player 1")
    game = GameService.state(game_id)
    assert hd(game.players).name == "Player 1"
  end

  test "game IDs don't contain zeros or ohs" do
    for _n <- 1..1000 do
      game_id = GameService.new_game_id()
      assert String.match?(game_id, ~r/0/) == false
      assert String.match?(game_id, ~r/O/) == false
    end
  end
end
