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
end
