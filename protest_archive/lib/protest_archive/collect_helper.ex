defmodule ProtestArchive.CollectHelper do
  # API ##########################################################################

  @spec get_data!(tuple, number | String.t(), String.t()) :: list(map) | map
  def get_data!({type, tag}, num_results, from) do
    url({type, tag}, num_results, from)
    |> fetch_data!(type)
    |> decode_response(type)
  end

  # Helpers #######################################################################

  @spec fetch_data!(String.t(), atom) :: %HTTPoison.Response{}
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

  # building url #######################################################

  @spec url(tuple, number, String.t()) :: String.t()
  def url({type, tag}, num_results, from) do
    base_url(type, num_results, from)
    |> add_tag(type, tag)
  end

  @spec base_url(atom, number | String.t(), String.t()) :: String.t()
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
    "https://api.twitter.com/1.1/search/tweets.json?lang=en&count=#{num_results}&tweet_mode=extended&"
  end

  @spec add_tag(String.t(), atom, String.t()) :: String.t()
  defp add_tag(url, _type = :news, tag) when is_bitstring(tag) do
    url <> "q=#{encode_tag(tag)}"
  end

  defp add_tag(url, _type = :tweet, tag) when is_bitstring(tag) do
    # if there is a string for a tweet, treat it as a combined hashtag
    tag = String.replace(tag, "\s", "")
    url <> "q=#{encode_tag("#" <> tag)}+AND+-filter:retweets"
  end

  @spec add_tag(String.t(), atom, list(String.t())) :: String.t()
  defp add_tag(url, _type = :tweet, tag) when is_list(tag) do
    url <> "q=#{encode_queries(tag)}"
  end

  # working with response ########################

  defp decode_response(response, _type = :news) do
    response |> handle_decode() |> change_news_sources_to_string()
  end

  defp decode_response(response, _type = :tweet) do
    response
    |> handle_decode()
    |> Access.get("statuses")
    |> filter_tweet_data()
  end

  @spec handle_decode(%HTTPoison.Response{}) :: list(map)
  defp handle_decode(response) do
    response
    |> Map.fetch!(:body)
    |> Poison.decode!()
  end

  @spec change_news_sources_to_string(list) :: list(map)
  defp change_news_sources_to_string(response) do
    response["articles"]
    |> Enum.map(fn article ->
      Map.update(article, "source", "", fn source -> source["name"] end)
    end)
  end

  def filter_tweet_data(response) do
    response
    |> Enum.map(fn tweet ->
      %{
        :author => tweet["user"]["name"],
        :authorHandle => "@#{tweet["user"]["screen_name"]}",
        :publishedAt => tweet["created_at"],
        :text => tweet["full_text"],
        :url => "https://twitter.com/#{tweet["user"]["id_str"]}/statuses/#{tweet["id_str"]}",
        :urlToProfileImage => tweet["user"]["profile_image_url_https"]
      }
    end)
  end

  # Helpers ###########################################################

  @spec encode_tag(String.t()) :: String.t()
  defp encode_tag(tag) do
    tag |> String.trim() |> String.downcase() |> URI.encode_www_form()
  end

  @spec encode_queries(list(String.t()), String.t()) :: String.t()
  defp encode_queries([head | tail], operator \\ "AND") do
    operator = String.upcase(operator)

    [head | Enum.map(tail, fn query -> " #{operator} " <> String.trim(query) end)]
    |> Enum.join()
    |> URI.encode_www_form()
  end
end
