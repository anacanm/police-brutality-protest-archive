defmodule ProtestArchive.DatabaseWorker do
  alias ProtestArchive.{Article, Tweet, Repo}
  import Ecto.Query, only: [from: 2]

  def get_between(:news, since, until) do
    handle_between(Article, since, until)
  end

  def get_between(:tweet, since, until) do
    handle_between(Tweet, since, until)
  end

  def get_since(:news, since) when is_bitstring(since) do
    {:ok, since, _} = DateTime.from_iso8601("#{since}T00:00:00Z")
    until = DateTime.truncate(DateTime.utc_now(), :second)

    handle_between(Article, since, until)
  end

  def get_since(:news, since) do
    until = DateTime.truncate(DateTime.utc_now(), :second)
    handle_between(Article, since, until)
  end

  def get_since(:tweet, since) when is_bitstring(since) do
    {:ok, since, _} = DateTime.from_iso8601("#{since}T00:00:00Z")
    until = DateTime.truncate(DateTime.utc_now(), :second)

    handle_between(Tweet, since, until)
  end

  def get_since(:tweet, since) do
    until = DateTime.truncate(DateTime.utc_now(), :second)
    handle_between(Tweet, since, until)
  end

  def insert(:news, data_to_insert) when is_list(data_to_insert) do
    Article.insert_all(data_to_insert)
  end

  def insert(:news, data_to_insert) do
    Article.insert_one(data_to_insert)
  end

  def insert(:tweet, data_to_insert) when is_list(data_to_insert) do
    Tweet.insert_all(data_to_insert)
  end

  def insert(:tweet, data_to_insert) do
    Tweet.insert_one(data_to_insert)
  end

  ## helpers

  defp handle_between(table_name, since, until) do
    query =
      from(d in table_name,
        where: d.published_at >= ^since and d.published_at <= ^until,
        select: d
      )

    Repo.all(query)
  end
end
