defmodule Rumbl.Repo.Migrations.CreateAnnotationsn do
  use Ecto.Migration

  def change do
    create table(:annotationsn) do
      add :body, :text
      add :at, :integer
      add :user_id, references(:users, on_delete: :nothing)
      add :video_is, references(:videos, on_delete: :nothing)

      timestamps()
    end

    create index(:annotationsn, [:user_id])
    create index(:annotationsn, [:video_is])
  end
end
