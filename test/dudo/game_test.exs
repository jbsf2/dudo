defmodule Dudo.GameTest do
  use ExUnit.Case, async: true

  alias Dudo.Game

  test "creating a game" do
    game = %Dudo.Game{}
    assert game != nil
    assert game.players == []
  end

  test "adding a player" do
    game = Game.new() |> Game.add_player({"john", "John"})
    [%Dudo.Player{id: player_id, name: player_name}] = game.players
    assert player_id == "john"
    assert player_name == "John"
  end

  test "losing and adding dice" do
    game =
      Game.new()
      |> Game.add_player({"john", "John"})
      |> Game.add_player({"marcia", "Marcia"})
      |> Game.lose_dice("marcia")

    marcia = Game.find_player(game, "marcia")
    assert length(marcia.dice) == 4

    game = Game.add_dice(game, "marcia")

    marcia = Game.find_player(game, "marcia")
    assert length(marcia.dice) == 5
  end

  test "player_status" do
    game = Game.new()
    assert Game.player_status(game, "1", "Player 1") == :not_playing
    game = Game.add_player(game, {"1", "Player 1"})
    assert Game.player_status(game, "1", "Player 1") == :already_playing
    assert Game.player_status(game, "1", "new name") == :already_playing
    assert Game.player_status(game, "2", "Player 1") == :name_collision
  end

  describe "can_see_dice" do
    test "when viewer is the dice owner, returns player_can_see_dice" do
      game =
        Game.new()
        |> Game.add_player({"1", "Player 1"})
        |> Game.add_player({"2", "Player 2"})
        |> Game.see_dice("1")

      assert game |> Game.can_see_dice(viewer: "1", dice_owner: "1") == true
      assert game |> Game.can_see_dice(viewer: "2", dice_owner: "2") == false
    end

    test "when viewer is not the dice owner, returns others_can_see_dice" do
      game =
        Game.new()
        |> Game.add_player({"1", "Player 1"})
        |> Game.add_player({"2", "Player 2"})
        |> Game.show_dice("1")

      assert game |> Game.can_see_dice(viewer: "2", dice_owner: "1") == true
      assert game |> Game.can_see_dice(viewer: "1", dice_owner: "2") == false
    end
  end

  describe "current_player_dice_visibility" do
    test "when the player has neither seen nor shown their dice" do
      game =
        Game.new()
        |> Game.add_player({"alice", "Alice"})
      assert game |> Game.current_player_dice_visibility("alice") == :nobody_can_see
    end

    test "when the player has seen but not shown their dice" do
      game =
        Game.new()
        |> Game.add_player({"alice", "Alice"})
        |> Game.see_dice("alice")
      assert game |> Game.current_player_dice_visibility("alice") == :only_you_can_see
    end

    test "when the player has shown but not seen their dice" do
      game =
        Game.new()
        |> Game.add_player({"alice", "Alice"})
        |> Game.show_dice("alice")
      assert game |> Game.current_player_dice_visibility("alice") == :everyone_else_can_see
    end

    test "when the player has seen and shown their dice" do
      game =
        Game.new()
        |> Game.add_player({"alice", "Alice"})
        |> Game.see_dice("alice")
        |> Game.show_dice("alice")
      assert game |> Game.current_player_dice_visibility("alice") == :everyone_can_see
    end
  end
end
