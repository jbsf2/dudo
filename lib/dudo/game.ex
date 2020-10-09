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
end
