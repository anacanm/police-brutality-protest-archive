defmodule ProtestArchive.Repo.Migrations.ChangeTweetIdToBigint do
  use Ecto.Migration

  def change do
    alter table(:tweets) do
      modify :tweet_id, :bigint
    end
  end
end
