defmodule InterfaceWeb.CacheController do
  use InterfaceWeb, :controller

  def index(conn, _params) do
    articles =
      ProtestArchive.CollectWorker.get_all_from_cache(:news)
      |> Enum.shuffle()
      |> Enum.slice(0, 20)

    tweets =
      ProtestArchive.CollectWorker.get_all_from_cache(:tweet)
      |> Enum.shuffle()
      |> Enum.slice(0, 14)

    render(conn, "index.html", articles: articles, tweets: tweets)
  end
end
