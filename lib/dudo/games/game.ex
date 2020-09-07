defmodule Dudo.Games.Game do
  use Ecto.Schema

  import Ecto.Changeset

  alias Dudo.Games.Game
  alias Dudo.Players.Player

  schema "games" do

    timestamps()

    belongs_to :creator, Player
  end

  @required_attrs ~w{creator_id}a

  def changeset(game, attrs) do
    game
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
  end

end