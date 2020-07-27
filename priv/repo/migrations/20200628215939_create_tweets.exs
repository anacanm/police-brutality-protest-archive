defmodule ProtestArchive.Repo.Migrations.CreateTweets do
  use Ecto.Migration

  def change do
    create table(:tweets, primary_key: false) do
      add(:tweet_id, :id, primary_key: true)
      add(:author, :string)
      add(:author_handle, :string)
      add(:published_at, :utc_datetime)
      add(:tag, :string)
      add(:content, :string, size: 285)
      add(:url, :string, size: 350)
      add(:url_to_profile_image, :string, size: 350)
    end
  end
end
