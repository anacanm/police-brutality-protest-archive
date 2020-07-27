defmodule ProtestArchive.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def change do
    create table(:articles) do
      add(:title, :string)
      add(:author, :string)
      add(:source, :string)
      add(:url, :string, size: 350)
      add(:content, :string, size: 300)
      add(:description, :string, size: 300)
      add(:published_at, :utc_datetime)
      add(:url_to_image, :string, size: 350)
    end
  end
end
