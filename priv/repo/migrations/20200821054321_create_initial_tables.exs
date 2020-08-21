defmodule Dudo.Repo.Migrations.CreateInitialTables do
  use Ecto.Migration

  def up do
    create table("players") do
      add :name, :string
      timestamps()
    end

    create table("games") do
      add :created_by, references("players")
      timestamps()
    end

    create table("hands") do
      add :player_id, references("players", on_delete: :delete_all)
      add :game_id, references("games", on_delete: :delete_all)
      add :dice_count, :int
      add :dice1, :int
      add :dice2, :int
      add :dice3, :int
      add :dice4, :int
      add :dice5, :int
      timestamps()
    end
  end

  def down do
    drop table("hands")
    drop table("games")
    drop table("players")
  end
end
