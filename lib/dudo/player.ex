defmodule Dudo.Player do
  @type dice_value :: 1..6
  @type dice :: [dice_value()]

  @enforce_keys [:id, :name]
  defstruct [
    :id,
    :name,
    dice: [],
    player_can_see_dice: false,
    others_can_see_dice: false
  ]

  @type t :: %Dudo.Player{
    id: String.t(),
    name: String.t(),
    dice: dice(),
    player_can_see_dice: boolean(),
    others_can_see_dice: boolean()
  }

  @spec new(String.t()) :: t()
  def new(name) do
    Dudo.Player.new(UUID.uuid1(), name)
  end

  @spec new(String.t(), String.t(), integer()) :: t()
  def new(id, name, dice_count \\ 5) do
    %Dudo.Player{id: id, name: name, dice: random_dice(dice_count)}
  end

  @spec lose_dice(t()) :: t()
  def lose_dice(player) do
    player |> Map.merge(%{dice: random_dice(length(player.dice) - 1)})
  end

  @spec add_dice(t()) :: t()
  def add_dice(player) do
    player |> Map.merge(%{dice: random_dice(length(player.dice) + 1)})
  end

  @spec shake_dice(t()) :: t()
  def shake_dice(player) do
    player |> Map.merge(%{
      dice: random_dice(length(player.dice)),
      player_can_see_dice: false,
      others_can_see_dice: false
    })
  end

  @spec see_dice(t()) :: t()
  def see_dice(player) do
    player |> Map.merge(%{player_can_see_dice: true})
  end

  @spec show_dice(t()) :: t()
  def show_dice(player) do
    player |> Map.merge(%{others_can_see_dice: true})
  end

  @spec random_dice(integer()) :: dice()
  def random_dice(count) when count <= 0 do
    []
  end

  def random_dice(count), do: for(_ <- 1..count, do: :rand.uniform(6))
end
