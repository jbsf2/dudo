defmodule Dudo.Game do
  defstruct players: []

  alias Dudo.Player

  def add_player(game, player_name) do
    player = Player.new_player(player_name) # change to just new instead of new_player
    %__MODULE__{players: game.players ++ [player]}
  end

  def lose_dice(game, player_name) do
    players = Enum.map(game.players, fn player ->
      if (player.name == player_name), do: Player.lose_dice(player), else: player
    end)

    %__MODULE__{players: players}
  end

  def add_dice(game, player_name) do
    players = Enum.map(game.players, fn player ->
      if (player.name == player_name), do: Player.add_dice(player), else: player
    end)

    %__MODULE__{players: players}
  end

  def find_player(game, player_name), do: Enum.find(game.players, &(&1.name == player_name))
end
