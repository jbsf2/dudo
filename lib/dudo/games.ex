defmodule Dudo.Games do
  alias Dudo.Games.Game
  alias Dudo.Games.Player
  alias Dudo.Games.Hand
  alias Dudo.Repo

  def create_game(attrs), do: %Game{} |> change_game(attrs) |> Repo.insert()
  def create_game!(attrs), do: %Game{} |> change_game(attrs) |> Repo.insert!()
  def change_game(%Game{} = game, attrs), do: Game.changeset(game, attrs)
  def get_game(id), do: Game |> Repo.get(id)

  # players
  def create_player(attrs), do: %Player{} |> change_player(attrs) |> Repo.insert()
  def create_player!(attrs), do: %Player{} |> change_player(attrs) |> Repo.insert!()
  def change_player(%Player{} = player, attrs), do: Player.changeset(player, attrs)
  def list_players(), do: Player.Query.all() |> Repo.all()
  def get_player(id), do: Player |> Repo.get(id)

  # hands
  def create_hand(attrs), do: %Hand{} |> change_hand(attrs) |> Repo.insert()
  def create_hand!(attrs), do: %Hand{} |> change_hand(attrs) |> Repo.insert!()
  def change_hand(%Hand{} = hand, attrs), do: Hand.changeset(hand, attrs)
  def preload_hands(game), do: game |> Repo.preload(:hands)


end