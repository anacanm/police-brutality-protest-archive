defmodule ProtestArchive.CollectHelper do
  # API ##########################################################################

  def get_data!({type, tag}, num_results, from) do
    url({type, tag}, num_results, from)
    |> fetch_data!(type)
  end

  # Helper #######################################################################

  defp fetch_data!(url, :news) when is_bitstring(url) do
    # the news api stores the auth key in the url, so no headers are needed
    url
    |> HTTPoison.get!()
  end

  defp fetch_data!(url, :tweet) when is_bitstring(url) do
    # the twitter api uses an oath 2 bearer token in the header to authenticate, so it needs to be added

    headers = [
      Authorization: "Bearer #{Application.fetch_env!(:protest_archive, :twitter_bearer_token)}"
    ]

    HTTPoison.get!(url, headers)
  end

  def url({type, tag}, num_results, from) do
    base_url(type, num_results, from)
    |> add_tag(type, tag)
  end

  defp base_url(:news, num_results, _from = nil) do
    # if no _from is provided (default val is nil), let news api calculate oldest date
    "https://newsapi.org/v2/everything?language=en&pageSize=#{num_results}&apiKey=#{
      Application.fetch_env!(:protest_archive, :news_api_key)
    }&"
  end

  defp base_url(:news, num_results, from) do
    "https://newsapi.org/v2/everything?language=en&pageSize=#{num_results}&from=#{from}&apiKey=#{
      Application.fetch_env!(:protest_archive, :news_api_key)
    }&"
  end

  defp base_url(:tweet, num_results, _from) do
    "https://api.twitter.com/1.1/search/tweets.json?lang=en&count=#{num_results}&"
  end

  defp add_tag(url, _type = :news, tag) when is_bitstring(tag) do
    url <> "q=#{encode_tag(tag)}"
  end

  defp add_tag(url, _type = :tweet, tag) when is_bitstring(tag) do
    # if there is a string for a tweet, treat it as a combined hashtag
    tag = String.replace(tag, "\s", "")
    url <> "q=#{encode_tag("#" <> tag)}"
  end

  defp add_tag(url, _type = :tweet, tag) when is_list(tag) do
    url <> "q=#{encode_queries(tag)}"
  end

  # Helpers ###########################################################

  defp encode_tag(tag) do
    tag |> String.trim() |> String.downcase() |> URI.encode_www_form()
  end

  defp encode_queries([head | tail], operator \\ "AND") do
    operator = String.upcase(operator)

    [head | Enum.map(tail, fn query -> " #{operator} " <> String.trim(query) end)]
    |> Enum.join()
    |> URI.encode_www_form()
  end
end
