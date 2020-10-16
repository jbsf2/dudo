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
end
