defmodule Dudo.GameTest do
  use ExUnit.Case, async: true

  alias Dudo.Game

  test "creating a game" do
    game = %Dudo.Game{}
    assert game != nil
    assert game.players == []
    assert game.mode == :closed
  end

  test "adding a player" do
    game = Game.new("john")
    [%Dudo.Player{name: player_name}] = game.players
    assert player_name == "john"
  end

  test "losing and adding dice" do
    game =
      Game.new("john")
      |> Game.add_player("marcia")
      |> Game.lose_dice("marcia")

    marcia = Game.find_player(game, "marcia")
    assert length(marcia.dice) == 4

    game = Game.add_dice(game, "marcia")

    marcia = Game.find_player(game, "marcia")
    assert length(marcia.dice) == 5
  end

  test "losing or adding dice resets game to closed mode" do
    game =
      Game.new("marcia")
      |> Game.set_mode(:open)
      |> Game.lose_dice("marcia")

    assert game.mode == :closed

    game =
      game
      |> Game.set_mode(:open)
      |> Game.add_dice("marcia")

    assert game.mode == :closed
  end

  test "revealing dice" do
    game =
      Game.new("jane")
      |> Game.reveal_dice("jane")

    player = Game.find_player(game, "jane")

    assert player.dice_visibility == :revealed
  end

  test "player_exists?" do
    game = Game.new("jane")
    assert game |> Game.player_exists?("jane") == true
    assert game |> Game.player_exists?("does not exist") == false
  end

  describe "can_see_dice" do
    test "when viewer is the dice owner, returns true" do
      game =
        Game.new("hidden")
        |> Game.add_player("revealed")
        |> Game.reveal_dice("revealed")

      assert game |> Game.can_see_dice("hidden", "hidden") == true
      assert game |> Game.can_see_dice("revealed", "revealed") == true
    end

    test "when viewer is not the dice owner, returns the owner's dice_visibility" do
      game =
        Game.new("hidden")
        |> Game.add_player("revealed")
        |> Game.reveal_dice("revealed")
        |> Game.add_player("viewer")

      assert game |> Game.can_see_dice("viewer", "hidden") == false
      assert game |> Game.can_see_dice("viewer", "revealed") == true
    end

    test "when game is in open mode, players can see others' dice but not their own, until they're revealed" do
      game =
        Game.new("alice")
        |> Game.add_player("bob")
        |> Game.set_mode(:open)

      assert game |> Game.can_see_dice("alice", "alice") == false
      assert game |> Game.can_see_dice("alice", "bob") == true
      assert game |> Game.can_see_dice("bob", "alice") == true
      assert game |> Game.can_see_dice("bob", "bob") == false

      game = game |> Game.reveal_dice("alice")

      assert game |> Game.can_see_dice("alice", "alice") == true
      assert game |> Game.can_see_dice("alice", "bob") == true
      assert game |> Game.can_see_dice("bob", "alice") == true
      assert game |> Game.can_see_dice("bob", "bob") == false

      game = game |> Game.reveal_dice("bob")

      assert game |> Game.can_see_dice("alice", "alice") == true
      assert game |> Game.can_see_dice("alice", "bob") == true
      assert game |> Game.can_see_dice("bob", "alice") == true
      assert game |> Game.can_see_dice("bob", "bob") == true
    end
  end

  describe "current_player_dice_visibility" do
    test "when game is in closed mode, it returns :only_you_can_see if the player's dice are hidden" do
      game = Game.new("alice")
      assert game |> Game.current_player_dice_visibility("alice") == :only_you_can_see
    end

    test "when game is in closed mode, it returns :everyone_can_see iff the player's dice are revealed" do
      game = Game.new("alice") |> Game.reveal_dice("alice")
      assert game |> Game.current_player_dice_visibility("alice") == :everyone_can_see
    end

    test "when game is in open mode, it returns :everyone_else_can_see iff player's dice are hidden" do
      game = Game.new("alice") |> Game.set_mode(:open)
      assert game |> Game.current_player_dice_visibility("alice") == :everyone_else_can_see
    end

    test "when game is in open mode, it returns :everyone_can_see iff the player's dice are revealed" do
      game = Game.new("alice") |> Game.set_mode(:open) |> Game.reveal_dice("alice")
      assert game |> Game.current_player_dice_visibility("alice") == :everyone_can_see
    end
  end
end
