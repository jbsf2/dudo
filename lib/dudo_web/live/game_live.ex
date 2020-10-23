defmodule DudoWeb.GameLive do
  use Phoenix.HTML
  use Phoenix.LiveView
  import DudoWeb.Router.Helpers, [:login_path]

  alias Dudo.GameService

  def mount(%{"id" => game_id}, %{"player_name" => current_player}, socket) do
    players = GameService.state(game_id).players

    socket =
      socket
      |> assign(:players, players)
      |> assign(:game_id, game_id)
      |> assign(:current_player, current_player)

    {:ok, socket}
  end

  @doc """
  Redirects to login when user not logged in.
  """
  def mount(%{"id" => _game_id}, %{}, socket) do
    socket = redirect(socket, to: login_path(socket, :new))
    {:ok, socket}
  end

  def handle_event("lose_dice", _params, socket) do
    {game_id, current_player} = session_data(socket)

    GameService.lose_dice(game_id, current_player)
    players = GameService.state(game_id).players

    {:noreply, assign(socket, :players, players)}
  end

  def handle_event("add_dice", _params, socket) do
    {game_id, current_player} = session_data(socket)

    GameService.add_dice(game_id, current_player)
    players = GameService.state(game_id).players

    {:noreply, assign(socket, :players, players)}
  end

  defp session_data(socket) do
    %{game_id: game_id, current_player: current_player} = socket.assigns
    {game_id, current_player}
  end
end
