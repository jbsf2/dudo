defmodule Dudo.GamesTest do
  use Dudo.DataCase, async: true

  alias Dudo.Games
  alias Dudo.Players

  test "create_game creates a game with a creator" do
    {:ok, player} = %{name: "Player 1"} |> Players.create_player()
    {:ok, game} = Games.create_game(%{creator_id: player.id})

    reloaded_game = Repo.preload(game, :creator, force: true)

    creator = reloaded_game.creator
    assert creator.id == player.id
  end

  test "create_game! creates a game with a creator" do
    {:ok, player} = %{name: "Player 1"} |> Players.create_player()
    game = Games.create_game!(%{creator_id: player.id}) |> Repo.preload(:creator, force: true)

    creator = game.creator
    assert creator.id == player.id
  end

  test "get_game returns a game" do
    player = %{name: "Player 1"} |> Players.create_player!()
    game = Games.create_game!(%{creator_id: player.id})
    fetched = Games.get_game(game.id)

    assert fetched.creator_id == player.id
  end
end