defmodule Dudo.Game do
  alias Dudo.Player

  @type current_player_dice_visibility ::
          :only_you_can_see | :everyone_can_see | :everyone_else_can_see
  @type players :: [Player.t()]

  defstruct players: []

  @type t :: %Dudo.Game{
          players: players()
        }

  @spec new() :: t()
  def new() do
    %Dudo.Game{}
  end

  @spec new(String.t()) :: t()
  def new(player_name) do
    %Dudo.Game{} |> add_player(player_name)
  end

  @spec add_player(t(), String.t()) :: t()
  def add_player(game, player_name) do
    new_player = Player.new(player_name)

    game
    |> Map.put(:players, [new_player | game.players])
  end

  @spec lose_dice(t(), String.t()) :: t()
  def lose_dice(game, player_name) do
    game
    |> update_player(player_name, &Player.lose_dice/1)
  end

  @spec add_dice(t(), String.t()) :: t()
  def add_dice(game, player_name) do
    game
    |> update_player(player_name, &Player.add_dice/1)
  end

  @spec see_dice(t(), String.t()) :: t()
  def see_dice(game, player_name) do
    game |> update_player(player_name, &Player.see_dice/1)
  end

  @spec show_dice(t(), String.t()) :: t()
  def show_dice(game, player_name) do
    game |> update_player(player_name, &Player.show_dice/1)
  end

  @spec shake_dice(t(), String.t()) :: t()
  def shake_dice(game, player_name) do
    game
    |> update_player(player_name, &Player.shake_dice/1)
  end

  @spec can_see_dice(t(), viewer: String.t(), dice_owner: String.t()) :: boolean()
  def can_see_dice(game, viewer: viewer_name, dice_owner: dice_owner_name) do
    case viewer_name == dice_owner_name do
      true -> game |> find_player(dice_owner_name) |> Map.get(:player_can_see_dice)
      false -> game |> find_player(dice_owner_name) |> Map.get(:others_can_see_dice)
    end
  end

  def current_player_dice_visibility(game, current_player_name) do
    player = game |> find_player(current_player_name)

    case player.player_can_see_dice do
      true -> case player.others_can_see_dice do
        true -> :everyone_can_see
        false -> :only_you_can_see
      end
      false -> case player.others_can_see_dice do
        true -> :everyone_else_can_see
        false -> :nobody_can_see
      end
    end
  end

  @spec find_player(t(), String.t()) :: Player.t()
  def find_player(game, player_name) do
    Enum.find(game.players, &(&1.name == player_name))
  end

  @spec player_exists?(t(), String.t()) :: boolean()
  def player_exists?(game, player_name) do
    find_player(game, player_name) != nil
  end

  @spec update_player(t(), String.t(), (Player.t() -> Player.t())) :: t()
  defp update_player(game, player_name, fun) do
    players =
      Enum.map(game.players, fn player ->
        if player.name == player_name, do: fun.(player), else: player
      end)

    game |> Map.put(:players, players)
  end
end
