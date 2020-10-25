defmodule Dudo.Player do
  @type dice_status :: :hidden | :revealed
  @type dice_value :: 1..6
  @type dice :: [dice_value()]

  @enforce_keys [:name]
  defstruct [:name, dice: [], dice_status: :hidden]

  @type t :: %Dudo.Player{
          name: String.t(),
          dice: dice(),
          dice_status: dice_status()
        }

  @spec new(String.t(), integer()) :: t()
  def new(name, dice_count \\ 5) do
    %Dudo.Player{name: name, dice: random_dice(dice_count), dice_status: :hidden}
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
  def shake_dice(player),
    do: %Dudo.Player{name: player.name, dice: random_dice(length(player.dice))}

  @spec random_dice(integer()) :: dice()
  def random_dice(count) when count <= 0 do
    []
  end

  def random_dice(count), do: for(_ <- 1..count, do: :rand.uniform(6))
end
