defmodule Dudo.Game do
  alias Dudo.Player

  @type players :: [Player.t()]

  defstruct players: []

  @type t :: %Dudo.Game {
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
    players =
      Enum.map(game.players, fn player ->
        if player.name == player_name, do: Player.lose_dice(player), else: player
      end)

    %Dudo.Game{players: players}
  end

  @spec add_dice(t(), String.t()) :: t()
  def add_dice(game, player_name) do
    players =
      Enum.map(game.players, fn player ->
        if player.name == player_name, do: Player.add_dice(player), else: player
      end)

    %Dudo.Game{players: players}
  end

  @spec find_player(t(), String.t()) :: t()
  def find_player(game, player_name), do: Enum.find(game.players, &(&1.name == player_name))
end
