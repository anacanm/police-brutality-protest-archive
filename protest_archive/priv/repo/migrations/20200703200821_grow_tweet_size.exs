defmodule ProtestArchive.Repo.Migrations.GrowTweetSize do
  use Ecto.Migration

  def change do
    alter table(:tweets) do
      modify :content, :string, size: 350
    end
  end
end
