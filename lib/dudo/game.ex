defmodule Dudo.Game do
  alias Dudo.Player

  @type game_mode :: :open | :closed
  @type current_player_dice_visibility ::
          :only_you_can_see | :everyone_can_see | :everyone_else_can_see
  @type players :: [Player.t()]

  defstruct players: [], round: [], mode: :closed

  @type t :: %Dudo.Game{
          players: players(),
          round: players(),
          mode: game_mode()
        }

  @spec new() :: t()
  def new() do
    %Dudo.Game{}
  end

  @spec new(String.t()) :: t()
  def new(player_name) do
    %Dudo.Game{} |> add_player(player_name)
  end

  @spec add_player(t(), String.t()) :: t()
  def add_player(game, player_name) do
    new_player = Player.new(player_name)

    game
    |> Map.put(:players, game.players ++ [new_player])
    |> add_player_to_round(player_name)
  end

  @spec lose_dice(t(), String.t()) :: t()
  def lose_dice(game, player_name) do
    game
    |> update_player(player_name, &Player.lose_dice/1)
    |> begin_new_round()
    |> add_player_to_round(player_name)
    |> set_mode(:closed)
  end

  @spec add_dice(t(), String.t()) :: t()
  def add_dice(game, player_name) do
    game
    |> update_player(player_name, &Player.add_dice/1)
    |> begin_new_round()
    |> add_player_to_round(player_name)
    |> set_mode(:closed)
  end

  @spec reveal_dice(t(), String.t()) :: t()
  def reveal_dice(game, player_name) do
    game |> update_player(player_name, &Player.reveal_dice/1)
  end

  @spec shake_dice(t(), String.t()) :: t()
  def shake_dice(game, player_name) do
    game
    |> update_player(player_name, &Player.shake_dice/1)
    |> add_player_to_round(player_name)
  end

  @spec can_see_dice(t(), String.t(), String.t()) :: boolean()
  def can_see_dice(game, viewer_name, dice_owner_name) do
    case game.mode do
      :closed ->
        if viewer_name == dice_owner_name do
          true
        else
          find_player(game, dice_owner_name).dice_visibility == :revealed
        end

      :open ->
        if viewer_name != dice_owner_name do
          true
        else
          find_player(game, dice_owner_name).dice_visibility == :revealed
        end
    end
  end

  def current_player_dice_visibility(game, current_player_name) do
    player = game |> find_player(current_player_name)

    case game.mode do
      :closed ->
        if player.dice_visibility == :hidden, do: :only_you_can_see, else: :everyone_can_see

      :open ->
        if player.dice_visibility == :hidden, do: :everyone_else_can_see, else: :everyone_can_see
    end
  end

  @spec can_shake_dice(t(), String.t()) :: boolean()
  def can_shake_dice(game, player_name) do
    game.round |> Enum.member?(player_name) == false
  end

  @spec find_player(t(), String.t()) :: Player.t()
  def find_player(game, player_name) do
    Enum.find(game.players, &(&1.name == player_name))
  end

  @spec player_exists?(t(), String.t()) :: boolean()
  def player_exists?(game, player_name) do
    find_player(game, player_name) != nil
  end

  @spec update_player(t(), String.t(), (Player.t() -> Player.t())) :: t()
  defp update_player(game, player_name, fun) do
    players =
      Enum.map(game.players, fn player ->
        if player.name == player_name, do: fun.(player), else: player
      end)

    game |> Map.put(:players, players)
  end

  @spec set_mode(t(), game_mode()) :: t()
  def set_mode(game, mode) do
    game |> Map.put(:mode, mode)
  end

  @spec begin_new_round(t()) :: t()
  defp begin_new_round(game) do
    game |> Map.put(:round, [])
  end

  @spec add_player_to_round(t(), String.t()) :: t()
  defp add_player_to_round(game, player_name) do
    game |> Map.put(:round, game.round ++ [player_name])
  end
end
