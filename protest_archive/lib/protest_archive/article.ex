defmodule ProtestArchive.Article do
  use Ecto.Schema

  schema "articles" do
    field(:title, :string)
    field(:author, :string)
    field(:source, :string)
    field(:url, :string)
    field(:content, :string)
    field(:description, :string)
    field(:published_at, :utc_datetime)
    field(:url_to_image, :string)
    field(:tag, :string)
  end

  def changeset(article, params \\ %{}) do
    article
    |> Ecto.Changeset.cast(params, fields())
    |> Ecto.Changeset.validate_required(fields())
  end

  defp fields do
    [:title, :author, :source, :url, :content, :description, :published_at, :url_to_image, :tag]
  end
end
