defmodule ProtestArchive.Article do
  use Ecto.Schema
  alias ProtestArchive.{Repo, Article}

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


  @spec insert_one(map) :: {:ok, %ProtestArchive.Article{}} | {:error, term}
  def insert_one(params) do
    changeset(%Article{}, params)
    |> Repo.insert()
  end

  @spec changeset(%ProtestArchive.Article{}, map) :: term
  def changeset(article, params \\ %{}) do
    article
    |> Ecto.Changeset.cast(params, fields())
    |> Ecto.Changeset.unique_constraint([:title, :author])
    |> Ecto.Changeset.validate_required(fields())
  end

  defp fields do
    [:title, :author, :source, :url, :content, :description, :published_at, :url_to_image, :tag]
  end
end
