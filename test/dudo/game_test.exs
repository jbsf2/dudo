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

  describe "shaking dice permissions" do
    test "a player can't shake again until someone loses or wins a dice" do
      game =
        Game.new("alice")
        |> Game.add_player("bob")
        |> Game.add_player("chris")

      assert game |> Game.can_shake_dice("alice") == false
      assert game |> Game.can_shake_dice("bob") == false

      game = game |> Game.lose_dice("alice")
      assert game |> Game.can_shake_dice("alice") == false
      assert game |> Game.can_shake_dice("bob") == true

      game = game |> Game.shake_dice("bob")
      assert game |> Game.can_shake_dice("alice") == false
      assert game |> Game.can_shake_dice("bob") == false
    end
  end
end
