defmodule ProtestArchive.Repo.Migrations.ChangeUrlSizeTo350 do
  use Ecto.Migration

  def change do
    alter table(:articles) do
      modify :url, :string, size: 350
      modify :url_to_image, :string, size: 350
    end
  end
end
