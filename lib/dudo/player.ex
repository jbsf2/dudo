defmodule Dudo.Player do
  @type dice_visibility :: :hidden | :revealed
  @type dice_value :: 1..6
  @type dice :: [dice_value()]

  @enforce_keys [:name]
  defstruct [:name, dice: [], dice_visibility: :hidden]

  @type t :: %Dudo.Player{
          name: String.t(),
          dice: dice(),
          dice_visibility: dice_visibility()
        }

  @spec new(String.t(), integer()) :: t()
  def new(name, dice_count \\ 5) do
    %Dudo.Player{name: name, dice: random_dice(dice_count), dice_visibility: :hidden}
  end

  @spec lose_dice(t()) :: t()
  def lose_dice(player) do
    %Dudo.Player{name: player.name, dice: random_dice(length(player.dice) - 1)}
  end

  @spec add_dice(t()) :: t()
  def add_dice(player) do
    %Dudo.Player{name: player.name, dice: random_dice(length(player.dice) + 1)}
  end

  @spec shake_dice(t()) :: t()
  def shake_dice(player) do
    %Dudo.Player{name: player.name, dice: random_dice(length(player.dice))}
  end

  @spec reveal_dice(t()) :: t()
  def reveal_dice(player) do
    %Dudo.Player{name: player.name, dice: player.dice, dice_visibility: :revealed}
  end

  @spec random_dice(integer()) :: dice()
  def random_dice(count) when count <= 0 do
    []
  end

  def random_dice(count), do: for(_ <- 1..count, do: :rand.uniform(6))
end
