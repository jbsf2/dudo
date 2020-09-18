defmodule Dudo.GamesTest do
  use Dudo.DataCase, async: true

  alias Dudo.Games

  test "create_player creates a player" do
    {:ok, player} = %{name: "Player 1"} |> Games.create_player()

    assert player.name == "Player 1"
  end

  test "create_player! creates a player" do
    player = %{name: "Player 1"} |> Games.create_player!()

    assert player.name == "Player 1"
  end


  test "get_player finds an existing player" do
    {:ok, player} = %{name: "Player 1"} |> Games.create_player()

    fetched_player = Games.get_player(player.id)

    assert fetched_player.id == player.id
    assert fetched_player.name == player.name

  end

  test "create_game creates a game with a creator" do
    {:ok, player} = %{name: "Player 1"} |> Games.create_player()
    {:ok, game} = Games.create_game(%{creator_id: player.id})

    reloaded_game = Repo.preload(game, :creator, force: true)

    creator = reloaded_game.creator
    assert creator.id == player.id
  end

  test "create_game! creates a game with a creator" do
    {:ok, player} = %{name: "Player 1"} |> Games.create_player()
    game = Games.create_game!(%{creator_id: player.id}) |> Repo.preload(:creator, force: true)

    creator = game.creator
    assert creator.id == player.id
  end

  test "get_game returns a game" do
    player = %{name: "Player 1"} |> Games.create_player!()
    game = Games.create_game!(%{creator_id: player.id})
    fetched = Games.get_game(game.id)

    assert fetched.creator_id == player.id
  end

  test "create_hand creates a hand" do
    player = %{name: "Player 1"} |> Games.create_player!()
    game = %{creator_id: player.id} |> Games.create_game!()

    hand = %{player_id: player.id, game_id: game.id, dice: [1, 2, 3, 4, 5]} |> Games.create_hand!()

    assert hand.dice == [1, 2, 3, 4, 5]
    assert hand.player_id == player.id
    assert hand.game_id == game.id
  end

    test "creating / reading multiple hands for a game" do
      player1 = %{name: "Player 1"} |> Games.create_player!()
      player2 = %{name: "Player 2"} |> Games.create_player!()
      player3 = %{name: "Player 3"} |> Games.create_player!()

      game = %{creator_id: player1.id} |> Games.create_game!()

      %{player_id: player1.id, game_id: game.id, dice: [1]} |> Games.create_hand!()
      %{player_id: player2.id, game_id: game.id, dice: [2]} |> Games.create_hand!()
      %{player_id: player3.id, game_id: game.id, dice: [3]} |> Games.create_hand!()

      %Games.Game{hands: hands} = Games.preload_hands(game)

      assert length(hands) == 3
    end
end