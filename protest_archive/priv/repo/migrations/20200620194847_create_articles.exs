defmodule ProtestArchive.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def change do
    create table(:articles) do
      add(:title, :string)
      add(:author, :string)
      add(:source, :string)
      add(:url, :string)
      add(:content, :string)
      add(:description, :string)
      add(:published_at, :string)
      add(:url_to_image, :string)
    end
  end
end
