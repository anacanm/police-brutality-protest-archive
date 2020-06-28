defmodule ProtestArchive.Article do
  use Ecto.Schema
  alias ProtestArchive.{Repo, Article}
  import Ecto.Query, only: [from: 2]

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

  @spec insert_all(list(map)) :: list(term)
  def insert_all(list_of_params) do
    # insert_all is not optimized, but I need to move on.
    # however, this lack of optimization is okay, because there are a fixed amount (not dynamic)
    # of insertions to the database in a given period of time

    list_of_params
    |> Enum.map(&insert_one(&1))
  end

  @spec insert_one(map) :: {:ok, %ProtestArchive.Article{}} | {:error, term}
  def insert_one(params) do
    changeset(%Article{}, params)
    |> Repo.insert()
  end

  @spec changeset(%ProtestArchive.Article{}, map) :: term
  def changeset(article, params \\ %{}) do
    fields = [:title, :author, :source, :url, :content, :description, :published_at, :url_to_image, :tag]

    required_fields = [:title, :source, :url, :content, :description, :published_at, :url_to_image, :tag]

    article
    |> Ecto.Changeset.cast(params, fields)
    |> Ecto.Changeset.unique_constraint([:title, :author])
    |> Ecto.Changeset.validate_required(required_fields)
  end

  def since(since) when is_bitstring(since) do
    {:ok, since, _} = DateTime.from_iso8601("#{since}T00:00:00Z")
    until = DateTime.truncate(DateTime.utc_now(), :second)

    handle_between(since, until)
  end

  def since(since) do
    until = DateTime.truncate(DateTime.utc_now(), :second)

    handle_between(since, until)
  end

  def between(since, until) when is_bitstring(since) and is_bitstring(until) do
    {:ok, since, _} = DateTime.from_iso8601("#{since}T00:00:00Z")
    {:ok, until, _} = DateTime.from_iso8601("#{until}T00:00:00Z")

    handle_between(since, until)
  end

  def between(since, until), do: handle_between(since, until)

  @spec handle_between(DateTime.t(), DateTime.t()) :: term()
  defp handle_between(since, until) do
    query =
      from(a in Article,
        where: a.published_at >= ^since and a.published_at <= ^until,
        select: a
      )

    Repo.all(query)
  end
end
