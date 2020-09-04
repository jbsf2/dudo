defmodule Dudo.Players do
  alias Dudo.Players.Player
  alias Dudo.Repo

  def create_player(attrs), do: %Player{} |> change_player(attrs) |> Repo.insert()
  def change_player(%Player{} = player, attrs), do: Player.changeset(player, attrs)
  def list_players(), do: Player.Query.all() |> Repo.all()

  #  def get_user(id), do: User |> Repo.get(id)
  #  def create_user!(attrs), do: %User{} |> change_user(attrs) |> Repo.insert!()

end
