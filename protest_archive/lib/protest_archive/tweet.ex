defmodule ProtestArchive.Tweet do
  use Ecto.Schema
  @primary_key {:tweet_id, :id, autogenerate: false}

  schema "tweets" do
    # field(:tweet_id, :integer, primary_key: true)
    field(:author, :string)
    field(:author_handle, :string)
    field(:published_at, :utc_datetime)
    field(:tag, :string)
    field(:content, :string)
    field(:url, :string)
    field(:url_to_profile_image, :string)
  end

  @spec changeset(%ProtestArchive.Tweet{}, map) :: term
  def changeset(tweet, params \\ %{}) do
    fields = [:author, :author_handle, :content, :published_at, :tag, :tweet_id, :url, :url_to_profile_image]
    required_fields = [:author, :author_handle, :content, :published_at, :tag, :tweet_id, :url]

    tweet
    |> Ecto.Changeset.cast(params, fields)
    |> Ecto.Changeset.validate_required(required_fields)
    |> Ecto.Changeset.unique_constraint(:tweet_id)
  end
end
