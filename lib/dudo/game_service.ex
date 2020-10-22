defmodule Dudo.GameService do
  use GenServer

  alias Dudo.Game

  def state(game_id) do
    GenServer.call(via_tuple(game_id), :state)
  end

  def add_player(game_id, player_name) do
    GenServer.cast(via_tuple(game_id), {:add_player, player_name})
  end

  def add_dice(game_id, player_name) do
    GenServer.cast(via_tuple(game_id), {:add_dice, player_name})
  end

  def lose_dice(game_id, player_name) do
    GenServer.cast(via_tuple(game_id), {:lose_dice, player_name})
  end

  def new_game(player_name) do
    game_id = new_game_id()

    DynamicSupervisor.start_child(:game_supervisor, {__MODULE__, {game_id, player_name}})

    game_id
  end

  def start_link({game_id, player_name}) do
    GenServer.start_link(
      __MODULE__,
      Game.new(player_name),
      name: via_tuple(game_id)
    )
  end

  defp via_tuple(game_id) do
    {:via, Registry, {:game_id_registry, game_id}}
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

  @impl true
  def init(%Dudo.Game{} = game) do
    {:ok, game}
  end

  @impl true
  def handle_call(:state, _from, game) do
    {:reply, game, game}
  end

  @impl true
  def handle_cast({:add_player, player_name}, game) do
    {:noreply, game |> Game.add_player(player_name)}
  end

  @impl true
  def handle_cast({:add_dice, player_name}, game) do
    {:noreply, game |> Game.add_dice(player_name)}
  end

  @impl true
  def handle_cast({:lose_dice, player_name}, game) do
    {:noreply, game |> Game.lose_dice(player_name)}
  end
end
