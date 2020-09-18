defmodule Dudo.Games.Game do
  use Ecto.Schema

  import Ecto.Changeset

  alias Dudo.Games.Game
  alias Dudo.Games.Player
  alias Dudo.Games.Hand

  schema "games" do

    timestamps()

    belongs_to :creator, Player
    has_many :hands, Hand
  end

  @required_attrs ~w{creator_id}a

  def changeset(game, attrs) do
    game
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
  end

end