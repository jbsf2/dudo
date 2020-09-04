defmodule Dudo.Players.Player do
  use Ecto.Schema

  import Ecto.Changeset

  alias Dudo.Players.Player

  schema "players" do
    field :name, :string
    timestamps()
  end

  @required_attrs ~w{name}a

  def changeset(player, attrs) do
    player
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
  end

  defmodule Query do
    import Ecto.Query

    def all() do
      from player in Player
    end
  end
end
