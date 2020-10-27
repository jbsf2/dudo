defmodule DudoWeb.GameLive do
  use Phoenix.HTML
  use Phoenix.LiveView
  import DudoWeb.Router.Helpers, [:login_path]

  alias Dudo.GameService
  alias Dudo.Game

  def mount(%{"id" => game_id}, %{"player_name" => current_player_name}, socket) do
    game = GameService.state(game_id)
    current_player = Game.find_player(game, current_player_name)

    socket =
      socket
      |> assign(:game_id, game_id)
      |> assign(:game, game)
      |> assign(:current_player, current_player)

    DudoWeb.Endpoint.subscribe(game_id)
    {:ok, socket}
  end

  @doc """
  Redirects to login when user not logged in.
  """
  def mount(%{"id" => _game_id}, %{}, socket) do
    socket = redirect(socket, to: login_path(socket, :new))
    {:ok, socket}
  end

  # ask Greg whether this technique seems advisable
  @function_map %{
    "lose_dice" => &GameService.lose_dice/2,
    "add_dice" => &GameService.add_dice/2,
    "reveal_dice" => &GameService.reveal_dice/2,
    "shake_dice" => &GameService.shake_dice/2
  }

  def handle_event(action, _params, socket) do
    %{game_id: game_id, current_player: current_player} = socket.assigns
    fun = Map.get(@function_map, to_string(action))
    game = fun.(game_id, current_player.name)

    socket =
      socket
      |> assign(:game, game)
      |> assign(:current_player, Game.find_player(game, current_player.name))

    {:noreply, socket}
  end

  # ask Greg about this kind of pattern matching on arg type vs. using @specs
  def handle_info(%Dudo.Game{} = game, socket) do
    {:noreply, assign(socket, :game, game)}
  end
end
