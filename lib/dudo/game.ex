defmodule Dudo.Game do
  alias Dudo.Player

  @type players :: [Player.t()]

  defstruct players: []

  @type t :: %Dudo.Game{
          players: players()
        }

  @spec new(String.t()) :: t()
  def new(player_name) do
    %Dudo.Game{players: [Player.new(player_name)]}
  end

  @spec add_player(t(), String.t()) :: t()
  def add_player(game, player_name) do
    %Dudo.Game{players: game.players ++ [Player.new(player_name)]}
  end

  @spec lose_dice(t(), String.t()) :: t()
  def lose_dice(game, player_name) do
    update_player(game, player_name, &Player.lose_dice/1)
  end

  @spec add_dice(t(), String.t()) :: t()
  def add_dice(game, player_name) do
    update_player(game, player_name, &Player.add_dice/1)
  end

  @spec reveal_dice(t(), String.t()) :: t()
  def reveal_dice(game, player_name) do
    update_player(game, player_name, &Player.reveal_dice/1)
  end

  @spec can_see_dice(t(), String.t(), String.t()) :: boolean()
  def can_see_dice(game, viewer_name, dice_owner_name) do
    if viewer_name == dice_owner_name do
      true
    else
      find_player(game, dice_owner_name).dice_visibility == :revealed
    end
  end

  @spec find_player(t(), String.t()) :: Player.t()
  def find_player(game, player_name) do
    Enum.find(game.players, &(&1.name == player_name))
  end

  @spec update_player(t(), String.t(), (Player.t() -> Player.t())) :: t()
  defp update_player(game, player_name, fun) do
    players =
      Enum.map(game.players, fn player ->
        if player.name == player_name, do: fun.(player), else: player
      end)

    %Dudo.Game{players: players}
  end
end
