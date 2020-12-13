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


  @spec add_player(t(), {String.t(), String.t()}) :: t()
  def add_player(game, {player_id, player_name}) do
    new_player = Player.new(player_id, player_name)

    game
    |> Map.put(:players, [new_player | game.players])
  end

  @spec lose_dice(t(), String.t()) :: t()
  def lose_dice(game, player_id) do
    game
    |> update_player(player_id, &Player.lose_dice/1)
  end

  @spec add_dice(t(), String.t()) :: t()
  def add_dice(game, player_id) do
    game
    |> update_player(player_id, &Player.add_dice/1)
  end

  @spec see_dice(t(), String.t()) :: t()
  def see_dice(game, player_id) do
    game |> update_player(player_id, &Player.see_dice/1)
  end

  @spec show_dice(t(), String.t()) :: t()
  def show_dice(game, player_id) do
    game |> update_player(player_id, &Player.show_dice/1)
  end

  @spec shake_dice(t(), String.t()) :: t()
  def shake_dice(game, player_id) do
    game
    |> update_player(player_id, &Player.shake_dice/1)
  end

  @spec can_see_dice(t(), viewer: String.t(), dice_owner: String.t()) :: boolean()
  def can_see_dice(game, viewer: viewer_id, dice_owner: dice_owner_id) do
    case viewer_id == dice_owner_id do
      true -> game |> find_player(dice_owner_id) |> Map.get(:player_can_see_dice)
      false -> game |> find_player(dice_owner_id) |> Map.get(:others_can_see_dice)
    end
  end

  def current_player_dice_visibility(game, current_player_id) do
    player = game |> find_player(current_player_id)

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

  @spec find_player(t(), String.t()) :: Player.t() | nil
  def find_player(game, player_id) do
    Enum.find(game.players, &(&1.id == player_id))
  end

  @spec player_status(t(), String.t(), String.t()) :: atom()
  def player_status(game, player_id, player_name) do
    if (find_player(game, player_id) != nil) do
      :already_playing
    else
      case find_player_named(game, player_name) do
        nil -> :not_playing
        _ -> :name_collision
      end
    end
  end

  @spec find_player_named(t(), String.t()) :: Player.t() | nil
  defp find_player_named(game, player_name) do
    Enum.find(game.players, &(&1.name == player_name))
  end

  @spec update_player(t(), String.t(), (Player.t() -> Player.t())) :: t()
  defp update_player(game, player_id, fun) do
    players =
      Enum.map(game.players, fn player ->
        if player.id == player_id, do: fun.(player), else: player
      end)

    game |> Map.put(:players, players)
  end
end
