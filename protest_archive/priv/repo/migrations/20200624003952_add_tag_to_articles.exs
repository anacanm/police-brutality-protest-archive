defmodule ProtestArchive.Repo.Migrations.AddTagToArticles do
  use Ecto.Migration

  def change do
    alter table(:articles) do
      add :tag, :string
    end
  end
end
