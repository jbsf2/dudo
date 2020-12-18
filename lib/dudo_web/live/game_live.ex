defmodule DudoWeb.GameLive do
  use Phoenix.HTML
  use Phoenix.LiveView

  import DudoWeb.Router.Helpers, [:login_path, :live_path]

  alias Phoenix.LiveView.Socket
  alias Phoenix.PubSub
  alias Dudo.GameService
  alias Dudo.Game

  @doc """
  Redirect when user not logged in.
  """
  def mount(%{"id" => game_id}, session, socket) when session == %{} do
    {:ok, redirect(socket, to: game_path(socket, :show, game_id))}
  end

  def mount(%{"id" => game_id}, session, %Socket{connected?: connected?} = socket)
      when connected? do
    player_id = session |> Map.get("player_id")
    :ok = DudoWeb.Endpoint.subscribe("game:#{game_id}")
    {:ok, assigns(socket, game_id, player_id)}
  end

  def mount(%{"id" => game_id}, session, %Socket{connected?: connected?} = socket)
      when connected? == false do
    player_id = session |> Map.get("player_id")
    player_name = session |> Map.get("player_name")

    case GameService.already_playing?(game_id, player_id, player_name) do
      true -> {:ok, assigns(socket, game_id, player_id)}
      false -> {:ok, redirect(socket, to: game_path(socket, :show, game_id))}
    end
  end

  @function_map %{
    "lose_dice" => &GameService.lose_dice/2,
    "add_dice" => &GameService.add_dice/2,
    "see_dice" => &GameService.see_dice/2,
    "show_dice" => &GameService.show_dice/2,
    "shake_dice" => &GameService.shake_dice/2
  }

  def handle_event("start_new_game", _params, socket) do
    %{game_id: game_id, current_player: current_player} = socket.assigns
    new_game_id = GameService.new_game()
    new_game_link = live_url(socket, DudoWeb.GameLive, new_game_id)

    socket =
      socket
      |> assigns(game_id, current_player.id)
      |> assign(:new_game_link, new_game_link)

    :ok = PubSub.broadcast(Dudo.PubSub, "game:#{game_id}", [new_game_link: new_game_link])
    {:noreply, socket}
  end

  def handle_event(action, _params, socket) do
    %{game_id: game_id, current_player: current_player} = socket.assigns
    fun = Map.get(@function_map, action)
    fun.(game_id, current_player.id)

    {:noreply, assigns(socket, game_id, current_player.id)}
  end

  def handle_info({:shake_dice, game, player_id}, socket) do
    socket =
      socket
      |> push_event(:shake, %{player_id: player_id})
      |> assign(:game, game)

    {:noreply, socket}
  end

  def handle_info([new_game_link: new_game_link], socket) do
    {:noreply, assign(socket, :new_game_link, new_game_link)}
  end

  def handle_info({_action, game, _player_id}, socket) do
    {:noreply, assign(socket, :game, game)}
  end

  @dice_visibility_messages %{
    nobody_can_see: "Nobody can see your dice",
    only_you_can_see: "Only you can see your dice",
    everyone_can_see: "Everyone can see your dice",
    everyone_else_can_see: "The other players can see your dice"
  }

  defp assigns(socket, game_id, current_player_id) do
    game = GameService.state(game_id)
    current_player = Game.find_player(game, current_player_id)

    current_player_dice_visibility =
      game |> Game.current_player_dice_visibility(current_player_id)

    dice_visibility_message = @dice_visibility_messages |> Map.get(current_player_dice_visibility)

    new_game_link = socket.assigns[:new_game_link]

    socket
    |> assign(:game_id, game_id)
    |> assign(:game, game)
    |> assign(:invitation_link, live_url(socket, DudoWeb.GameLive, game_id))
    |> assign(:current_player, current_player)
    |> assign(:dice_visibility_message, dice_visibility_message)
    |> assign(:new_game_link, new_game_link)
  end
end
