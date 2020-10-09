defmodule Dudo.PlayerTest do
  use ExUnit.Case, async: true

  alias Dudo.Player

  test "it has five dice on creation" do
    player = Player.new_player("Jill")
    dice = player.dice
    assert length(dice) == 5
  end

  test "random_dice returns the right count" do
    assert length(Player.random_dice(1)) == 1
    assert length(Player.random_dice(2)) == 2
    assert length(Player.random_dice(3)) == 3
    assert length(Player.random_dice(4)) == 4
  end

  test "random_dice returns the right values" do
    dice = Player.random_dice(1000)
    assert Enum.min(dice) == 1
    assert Enum.max(dice) == 6
  end

  test "lose_dice decrements the dice count, bottoming out at 0" do
    player = Player.new_player("Jill")
    |> Player.lose_dice()
    |> Player.lose_dice()
    |> Player.lose_dice()
    |> Player.lose_dice()
    |> Player.lose_dice()

    assert length(player.dice) == 0

    player = Player.lose_dice(player)

    assert length(player.dice) == 0
  end

  test "shuffle_dice" do
    player = Player.new_player("Jill", 100)
    shuffled = Player.shuffle_dice(player)

    assert player.dice != shuffled.dice
  end
end
