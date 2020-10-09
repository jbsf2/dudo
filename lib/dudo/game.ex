defmodule Dudo.Game do
  defstruct players: []

  def add_player(game, player_name) do
    player = Dudo.Player.new_player(player_name)
    %Dudo.Game{players: game.players ++ [player]}
  end
end
