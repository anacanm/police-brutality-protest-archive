defmodule ProtestArchive.DatabaseWorker do
  alias ProtestArchive.{Article, Tweet, Repo}
  import Ecto.Query, only: [from: 2]

  @doc """
  get_tag returns articles or tweets specified by the type and the tag.
  For specific ordering, pass a field to order_by, or nil for no ordering
  """
  def get_tag(:news, tag, order_by) do
    handle_tag(Article, tag, order_by)
  end

  def get_tag(:tweet, tag, order_by) do
    handle_tag(Tweet, tag, order_by)
  end

  def get_tag_between(type, tag, order_by, since, until \\ nil)

  def get_tag_between(:news, tag, order_by, since, until) do
    {:ok, since, _} = DateTime.from_iso8601("#{since}T00:00:00Z")
    until = handle_until(until)

    handle_tag_between(Article, tag, order_by, since, until)
  end

  def get_tag_between(:tweet, tag, order_by, since, until) do
    {:ok, since, _} = DateTime.from_iso8601("#{since}T00:00:00Z")
    until = handle_until(until)

    handle_tag_between(Tweet, tag, order_by, since, until)
  end

  # strings passed for the since and until params must be in format "YYYY-MM-DD"

  def get_between(type, order_by, since, until \\ nil)

  def get_between(:news, order_by, since, until) do
    {:ok, since, _} = DateTime.from_iso8601("#{since}T00:00:00Z")
    until = handle_until(until)
    handle_between(Article, order_by, since, until)
  end

  def get_between(:tweet, order_by, since, until) do
    {:ok, since, _} = DateTime.from_iso8601("#{since}T00:00:00Z")
    until = handle_until(until)
    handle_between(Tweet, order_by, since, until)
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

  ## queries

  defp handle_between(schema, order_by, since, until) do
    query =
      from(d in schema,
        where: d.published_at >= ^since and d.published_at <= ^until,
        order_by: d.tag,
        select: d
      )

    query = handle_order_by(query, order_by)
    Repo.all(query)
  end

  defp handle_tag(schema, tag, order_by) do
    query =
      from(d in schema,
        where: d.tag == ^tag,
        select: d
      )

    query = handle_order_by(query, order_by)
    Repo.all(query)
  end

  defp handle_tag_between(schema, tag, order_by, since, until) do
    query =
      from(d in schema,
        where: d.tag == ^tag and d.published_at >= ^since and d.published_at <= ^until,
        select: d
      )

    query = handle_order_by(query, order_by)
    Repo.all(query)
  end

  # helpers

  defp handle_until(until) do
    cond do
      until == nil ->
        DateTime.truncate(DateTime.utc_now(), :second)

      true ->
        {:ok, until, _} = DateTime.from_iso8601("#{until}T00:00:00Z")
        until
    end
  end

  defp handle_order_by(query, order) do
    cond do
      order == "tag" ->
        from(q in query, order_by: q.tag)

      order == "published_at" ->
        from(q in query, order_by: q.published_at)

      order == "author" ->
        from(q in query, order_by: q.author)

      true ->
        query
    end
  end
end
