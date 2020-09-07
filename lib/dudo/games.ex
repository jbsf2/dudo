defmodule Dudo.Games do
  alias Dudo.Games.Game
  alias Dudo.Repo

  def create_game(attrs), do: %Game{} |> change_game(attrs) |> Repo.insert()
  def create_game!(attrs), do: %Game{} |> change_game(attrs) |> Repo.insert!()
  def change_game(%Game{} = game, attrs), do: Game.changeset(game, attrs)
  def get_game(id), do: Game |> Repo.get(id)
end