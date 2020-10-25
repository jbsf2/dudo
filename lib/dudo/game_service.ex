defmodule Dudo.GameService do
  use GenServer

  # ask Greg about pubsub introducing a dependency on Phoenix
  alias Phoenix.PubSub
  alias Dudo.Game

  def new_game(player_name) do
    game_id = new_game_id()

    DynamicSupervisor.start_child(:game_supervisor, {__MODULE__, {game_id, player_name}})

    game_id
  end

  def state(game_id) do
    GenServer.call(via_tuple(game_id), :state)
  end

  # ask Greg whether it's worth trying to further reduce the boilerplate
  def add_player(game_id, player_name), do: call_and_broadcast(:add_player, game_id, player_name)
  def add_dice(game_id, player_name), do: call_and_broadcast(:add_dice, game_id, player_name)
  def lose_dice(game_id, player_name), do: call_and_broadcast(:lose_dice, game_id, player_name)

  def reveal_dice(game_id, player_name),
    do: call_and_broadcast(:reveal_dice, game_id, player_name)

  def start_link({game_id, player_name}) do
    GenServer.start_link(
      __MODULE__,
      Game.new(player_name),
      name: via_tuple(game_id)
    )
  end

  defp call_and_broadcast(action, game_id, player_name) do
    game = GenServer.call(via_tuple(game_id), {action, player_name})
    PubSub.broadcast(Dudo.PubSub, game_id, game)
    game
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

  # ask Greg whether this technique seems advisable
  @function_map %{
    add_player: &Game.add_player/2,
    add_dice: &Game.add_dice/2,
    lose_dice: &Game.lose_dice/2,
    reveal_dice: &Game.reveal_dice/2
  }

  @impl true
  def handle_call({action, player_name}, _from, game) do
    fun = Map.get(@function_map, action)
    game = game |> fun.(player_name)
    {:reply, game, game}
  end
end
