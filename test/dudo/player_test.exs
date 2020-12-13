defmodule Dudo.PlayerTest do
  use ExUnit.Case, async: true

  alias Dudo.Player

  test "it has five dice on creation" do
    player = Player.new("Jill")
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
    player =
      Player.new("Jill")
      |> Player.lose_dice()
      |> Player.lose_dice()
      |> Player.lose_dice()
      |> Player.lose_dice()
      |> Player.lose_dice()

    assert length(player.dice) == 0

    player = Player.lose_dice(player)

    assert length(player.dice) == 0
  end

  test "shake_dice" do
    player = Player.new("Jill", "Jill", 100)
    shaked = Player.shake_dice(player)

    assert player.dice != shaked.dice
  end

  test "see_dice" do
    player = Player.new("Jill")
    assert player.player_can_see_dice == :false
    player = Player.see_dice(player)
    assert player.player_can_see_dice == :true
  end

  test "show_dice" do
    player = Player.new("Jill")
    assert player.others_can_see_dice == :false
    player = Player.show_dice(player)
    assert player.others_can_see_dice == :true
  end
end
