defmodule Dudo.GameApi do
  def start() do
    pid = spawn(fn -> Dudo.GameServer.run(%Dudo.Game{}) end)
    game_id = new_game_id()
    Registry.put_meta(:game_id_registry, {game_id}, pid)
    game_id
  end

  def create_game(player_name) do
    game_id = start()
    add_player(game_id, player_name)
    game_id
  end

  def add_player(game_id, player_name) do
    send pid(game_id), {:add_player, player_name}
  end

  def lose_dice(game_id, player_name) do
    send pid(game_id), {:lose_dice, player_name}
  end

  def state(game_id) do
    send pid(game_id), {:state, self()}
    receive do
      %Dudo.Game{} = game -> game
    end
  end

  defp new_game_id do
    min = String.to_integer("1000", 36)
    max = String.to_integer("ZZZZ", 36)

    max
    |> Kernel.-(min)
    |> :rand.uniform()
    |> Kernel.+(min)
    |> Integer.to_string(36)
  end

  defp pid(game_id) do
    {:ok, pid} = Registry.meta(:game_id_registry, {game_id})
    pid
  end
end
