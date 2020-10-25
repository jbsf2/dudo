defmodule Dudo.GameTest do
  use ExUnit.Case, async: true

  alias Dudo.Game

  test "creating a game" do
    game = %Dudo.Game{}
    assert game != nil
    assert game.players == []
  end

  test "adding a player" do
    game = Game.add_player(%Dudo.Game{}, "john")
    [%Dudo.Player{name: player_name}] = game.players
    assert player_name == "john"
  end

  test "losing and adding dice" do
    game =
      Game.add_player(%Dudo.Game{}, "john")
      |> Game.add_player("marcia")
      |> Game.lose_dice("marcia")

    marcia = Game.find_player(game, "marcia")
    assert length(marcia.dice) == 4

    game = Game.add_dice(game, "marcia")

    marcia = Game.find_player(game, "marcia")
    assert length(marcia.dice) == 5
  end

  test "revealing dice" do
    game =
      Game.add_player(%Dudo.Game{}, "jane")
      |> Game.reveal_dice("jane")

    player = Game.find_player(game, "jane")

    assert player.dice_visibility == :revealed
  end

  describe "can_see_dice" do
    test "when viewer is the dice owner, returns true" do
      game =
        %Dudo.Game{}
        |> Game.add_player("hidden")
        |> Game.add_player("revealed")
        |> Game.reveal_dice("revealed")

      assert game |> Game.can_see_dice("hidden", "hidden") == true
      assert game |> Game.can_see_dice("revealed", "revealed") == true
    end

    test "when viewer is not the dice owner, returns the owner's dice_visibility" do
      game =
        %Dudo.Game{}
        |> Game.add_player("hidden")
        |> Game.add_player("revealed")
        |> Game.reveal_dice("revealed")
        |> Game.add_player("viewer")

      assert game |> Game.can_see_dice("viewer", "hidden") == false
      assert game |> Game.can_see_dice("viewer", "revealed") == true
    end
  end
end
