defmodule Dudo.GameServer do

  alias Dudo.Game

  def run(game) do
    new_game = listen(game)
    run(new_game)
  end

  def listen(game) do
    receive do
      {:add_player, player_name} ->
        Game.add_player(game, player_name)
      {:lose_dice, player_name} ->
        Game.lose_dice(game, player_name)
      {:state, pid} ->
        send pid, game
    end
  end
end
