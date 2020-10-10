defmodule Dudo.Player do
  @enforce_keys [:name, :dice]
  defstruct [:name, dice: []]

  def new_player(name, dice_count \\ 5) do
    %Dudo.Player{name: name, dice: random_dice(dice_count)}
  end

  def lose_dice(player) do
    %Dudo.Player{name: player.name, dice: random_dice(length(player.dice) - 1)}
  end

  def random_dice(count) when count <= 0 do [] end

  def random_dice(count) do
    for _ <- 1..count, do: :rand.uniform(6)
  end

  def shake_dice(player) do
    %Dudo.Player{name: player.name, dice: random_dice(length(player.dice))}
  end

end
