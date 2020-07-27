defmodule ProtestArchive.Repo.Migrations.AddArticleUniqueConstraint do
  use Ecto.Migration

  def change do
    create(unique_index(:articles, [:title, :author]))
  end
end
