defmodule Dudo.Game do
  defstruct players: []

  alias Dudo.Player

  def new(player_name) do
    %Dudo.Game{players: [Player.new(player_name)]}
  end

  def add_player(game, player_name) do
    %Dudo.Game{players: game.players ++ [Player.new(player_name)]}
  end

  def lose_dice(game, player_name) do
    players =
      Enum.map(game.players, fn player ->
        if player.name == player_name, do: Player.lose_dice(player), else: player
      end)

    %Dudo.Game{players: players}
  end

  def add_dice(game, player_name) do
    players =
      Enum.map(game.players, fn player ->
        if player.name == player_name, do: Player.add_dice(player), else: player
      end)

    %Dudo.Game{players: players}
  end

  def find_player(game, player_name), do: Enum.find(game.players, &(&1.name == player_name))
end
