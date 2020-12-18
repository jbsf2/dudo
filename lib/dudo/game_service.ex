defmodule Dudo.GameService do
  use GenServer

  alias Phoenix.PubSub
  alias Dudo.Game

  def new_game() do
    game_id = new_game_id()

    case DynamicSupervisor.start_child(:game_supervisor, {__MODULE__, {game_id}}) do
      {:ok, _pid} -> game_id
      {:error, {:already_started, _pid}} -> new_game()
    end
  end

  def exists?(game_id) do
    length(Registry.lookup(:game_id_registry, game_id)) > 0
  end

  def player_status(game_id, player_id, player_name) do
    state(game_id) |> Game.player_status(player_id, player_name)
  end

  def already_playing?(game_id, player_id, player_name) do
    exists?(game_id) &&
    player_status(game_id, player_id, player_name) == :already_playing
  end

  def state(game_id) do
    GenServer.call(via_tuple(game_id), :state)
  end

  def add_player(game_id, player_id, player_name) do
    call_and_broadcast(:add_player, game_id, {player_id, player_name})
  end

  def add_dice(game_id, player_name), do: call_and_broadcast(:add_dice, game_id, player_name)
  def lose_dice(game_id, player_name), do: call_and_broadcast(:lose_dice, game_id, player_name)
  def shake_dice(game_id, player_name), do: call_and_broadcast(:shake_dice, game_id, player_name)
  def see_dice(game_id, player_name), do: call_and_broadcast(:see_dice, game_id, player_name)
  def show_dice(game_id, player_name), do: call_and_broadcast(:show_dice, game_id, player_name)

  def start_link({game_id}) do
    GenServer.start_link(
      __MODULE__,
      Game.new(),
      name: via_tuple(game_id)
    )
  end

  defp call_and_broadcast(action, game_id, arg) do
    game = GenServer.call(via_tuple(game_id), {action, arg})
    :ok = PubSub.broadcast(Dudo.PubSub, "game:#{game_id}", {action, game, arg})
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
    |> replace("0")
    |> replace("O")
  end

  defp replace(base36_string, string_to_replace) do
    chars = '123456789ABCDEFGHIJKLMNPQRSTUVWXYZ'

    replacement_index = :rand.uniform(length(chars)) - 1
    {replacement_char, _} = chars |> List.pop_at(replacement_index)
    replacement_string = to_string([replacement_char])

    base36_string |> String.replace(string_to_replace, replacement_string)
  end

  @impl true
  def init(%Dudo.Game{} = game) do
    {:ok, game}
  end

  @impl true
  def handle_call(:state, _from, game) do
    {:reply, game, game}
  end

  @function_map %{
    add_player: &Game.add_player/2,
    add_dice: &Game.add_dice/2,
    lose_dice: &Game.lose_dice/2,
    see_dice: &Game.see_dice/2,
    show_dice: &Game.show_dice/2,
    shake_dice: &Game.shake_dice/2
  }

  @impl true
  def handle_call({action, arg}, _from, game) do
    fun = Map.get(@function_map, action)
    game = game |> fun.(arg)
    {:reply, game, game}
  end
end
