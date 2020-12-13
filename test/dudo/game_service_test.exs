defmodule Dudo.GameServiceTest do
  use ExUnit.Case

  alias Dudo.GameService

  test "adding a player" do
    game = GameService.new_game() |> GameService.add_player("Bob", "Bob")
    player = hd(game.players)
    assert player.name == "Bob"
  end

  test "losing and adding dice" do
    game_id = GameService.new_game()
    GameService.add_player(game_id, "Bob", "Bob")
    GameService.add_player(game_id, "Alice", "Alice")
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
    game_id = GameService.new_game()
    GameService.add_player(game_id, "Bob", "Bob")
    GameService.add_player(game_id, "Alice", "Alice")

    game = GameService.state(game_id)
    assert length(game.players) == 2

    GameService.add_player(game_id, "Jane", "Jane")
    game = GameService.state(game_id)
    assert length(game.players) == 3
  end

  test "create_game starts a game and adds a player" do
    game_id = GameService.new_game()
    game = GameService.add_player(game_id, "Player 1", "Player 1")
    assert hd(game.players).name == "Player 1"
  end

  test "game IDs don't contain zeros or ohs" do
    for _n <- 1..1000 do
      game_id = GameService.new_game()
      GameService.add_player(game_id, "Player 1", "Player 1")
      assert String.match?(game_id, ~r/0/) == false
      assert String.match?(game_id, ~r/O/) == false
    end
  end

  test "exists?" do
    exists = GameService.new_game()
    assert GameService.exists?(exists) == true
    assert GameService.exists?("does not exist") == false
  end

  test "player_status" do
    game_id = GameService.new_game()
    GameService.add_player(game_id, "1", "Player 1")
    assert GameService.player_status(game_id, "1", "Player 1") == :already_playing
  end
end
