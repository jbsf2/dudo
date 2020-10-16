defmodule Dudo.Game do
  defstruct players: []

  alias Dudo.Player

  def add_player(game, player_name) do
    player = Dudo.Player.new_player(player_name)
    %Dudo.Game{players: game.players ++ [player]}
  end

  def lose_dice(game, player_name) do
    players = Enum.map(game.players, fn player ->
      if (player.name == player_name), do: Player.lose_dice(player), else: player
    end)

    %Dudo.Game{players: players}
  end

  def add_dice(game, player_name) do
    players = Enum.map(game.players, fn player ->
      if (player.name == player_name), do: Player.add_dice(player), else: player
    end)

    %Dudo.Game{players: players}
  end

  def find_player(game, player_name) do
    Enum.find(game.players, fn player -> player.name == player_name end)
  end
end
