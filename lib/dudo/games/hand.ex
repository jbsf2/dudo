defmodule Dudo.Games.Hand do
  use Ecto.Schema

  import Ecto.Changeset

  alias Dudo.Games.Player
  alias Dudo.Games.Game

  schema "hands" do
    field :dice, {:array, :integer}
    timestamps()

    belongs_to :player, Player
    belongs_to :game, Game
  end

  @required_attrs ~w{dice player_id game_id}a

  def changeset(hand, attrs) do
    hand
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
  end
end
