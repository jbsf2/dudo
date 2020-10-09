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
end
