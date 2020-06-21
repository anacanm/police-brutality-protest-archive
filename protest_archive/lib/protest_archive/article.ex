defmodule ProtestArchive.Article do
  use Ecto.Schema

  schema "articles" do
    field(:title, :string)
    field(:author, :string)
    field(:source, :string)
    field(:url, :string)
    field(:content, :string)
    field(:description, :string)
    field(:published_at, :string)
    field(:url_to_image, :string)
  end
end