defmodule DudoWeb.GameLive do
  use Phoenix.HTML
  use Phoenix.LiveView
  import DudoWeb.Router.Helpers, [:login_path]

  alias Dudo.GameService
  alias Dudo.Game

  def mount(%{"id" => game_id}, %{"player_name" => current_player_name}, socket) do
    DudoWeb.Endpoint.subscribe("game:#{game_id}")
    {:ok, assigns(socket, game_id, current_player_name)}
  end

  @doc """
  Redirects to login when user not logged in.
  """
  def mount(%{"id" => _game_id}, %{}, socket) do
    socket = redirect(socket, to: login_path(socket, :new))
    {:ok, socket}
  end

  @function_map %{
    "lose_dice" => &GameService.lose_dice/2,
    "add_dice" => &GameService.add_dice/2,
    "reveal_dice" => &GameService.reveal_dice/2,
    "shake_dice" => &GameService.shake_dice/2
  }

  def handle_event(action, _params, socket) do
    %{game_id: game_id, current_player: current_player} = socket.assigns
    fun = Map.get(@function_map, action)
    fun.(game_id, current_player.name)

    {:noreply, assigns(socket, game_id, current_player.name)}
  end

  def handle_info({:shake_dice, game, player_name}, socket) do
    socket =
      socket
      |> push_event(:shake, %{player_name: player_name})
      |> assign(:game, game)

    {:noreply, socket}
  end

  def handle_info({_action, game, _player_name}, socket) do
    {:noreply, assign(socket, :game, game)}
  end

  @dice_visibility_messages %{
    only_you_can_see: "Only you can see your dice",
    everyone_can_see: "Everyone can see your dice",
    everyone_else_can_see: "You can't see your dice, but the other players can"
  }

  defp assigns(socket, game_id, current_player_name) do
    game = GameService.state(game_id)
    current_player = Game.find_player(game, current_player_name)

    current_player_dice_visibility = game |> Game.current_player_dice_visibility(current_player_name)
    dice_visibility_message = @dice_visibility_messages |> Map.get(current_player_dice_visibility)

    socket
    |> assign(:game_id, game_id)
    |> assign(:game, game)
    |> assign(:current_player, current_player)
    |> assign(:dice_visibility_message, dice_visibility_message)
  end
end
