defmodule Dudo.GameApi do
  def start() do
    spawn(fn -> Dudo.GameServer.run(%Dudo.Game{}) end)
  end

  def add_player(pid, player_name) do
    send pid, {:add_player, player_name}
  end

  def lose_dice(pid, player_name) do
    send pid, {:lose_dice, player_name}
  end

  def state(pid) do
    send pid, {:state, self()}
    receive do
      %Dudo.Game{} = game -> game
    end
  end
end
