defmodule Dudo.Repo.Migrations.ConvertDiceToArray do
  use Ecto.Migration

  def change do
    alter table("hands") do
      remove :dice_count, :int
      remove :dice1, :int
      remove :dice2, :int
      remove :dice3, :int
      remove :dice4, :int
      remove :dice5, :int

      add :dice, {:array, :int}
    end
  end
end
