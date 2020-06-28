defmodule ProtestArchive.CollectHelper do
  # API ##########################################################################

  @spec get_data!(tuple, number | String.t(), String.t()) :: list(map)
  def get_data!({type, tag}, num_results, from) do
    url({type, tag}, num_results, from)
    |> fetch_data!(type)
    |> decode_response(type)
    |> add_tag_to_response(tag)
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
  defp url({type, tag}, num_results, from) do
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

  defp base_url(:news, num_results, _from = "recent") do
    "https://newsapi.org/v2/everything?language=en&sortBy=publishedAt&pageSize=#{num_results}&apiKey=#{
      Application.fetch_env!(:protest_archive, :news_api_key)
    }&"
  end

  defp base_url(:news, num_results, from) do
    "https://newsapi.org/v2/everything?language=en&pageSize=#{num_results}&from=#{from}&apiKey=#{
      Application.fetch_env!(:protest_archive, :news_api_key)
    }&"
  end

  defp base_url(:tweet, num_results, _from = "recent") do
    "https://api.twitter.com/1.1/search/tweets.json?lang=en&result_type=recent&count=#{num_results}&tweet_mode=extended&"
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

  @spec decode_response(%HTTPoison.Response{}, atom) :: list(map)
  defp decode_response(response, _type = :news) do
    response
    |> handle_decode()
    |> change_news_sources_to_string()
    |> string_keys_to_atoms()
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
      article
      |> Map.update("source", "", fn source -> source["name"] end)
      |> Map.update("author", "", fn author -> author || "" end)
      |> Map.update("content", "", fn content -> content || article["description"] end)
      |> Map.update("published_at", DateTime.truncate(DateTime.utc_now(), :second), fn date_time ->
        from_iso_trunc(date_time)
      end)
    end)
  end

  defp filter_tweet_data(response) do
    response
    |> Enum.map(fn tweet ->
      %{
        :tweet_id => tweet["id"],
        :author => tweet["user"]["name"],
        :author_handle => "@#{tweet["user"]["screen_name"]}",
        :published_at => twitter_date_to_iso8601(tweet["created_at"]),
        :text => tweet["full_text"],
        :url => "https://twitter.com/#{tweet["user"]["id_str"]}/statuses/#{tweet["id_str"]}",
        :url_to_profile_image => tweet["user"]["profile_image_url_https"]
      }
    end)
  end

  @spec add_tag_to_response(list(map), String.t()) :: list(map)
  defp add_tag_to_response(response, tag) do
    response
    |> Enum.map(fn elem ->
      Map.update(elem, :tag, tag, fn _ -> tag end)
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

  @spec string_keys_to_atoms(list(map)) :: list(map)
  defp string_keys_to_atoms(list_of_maps) do
    list_of_maps
    |> Enum.map(fn map ->
      for {key, value} <- map, into: %{}, do: {atomify(key), value}
    end)
  end

  # converts camel-case strings to atoms
  # ex: atomify("helloWorld") -> hello_world
  @spec atomify(String.t()) :: atom
  defp atomify(elem) do
    elem
    |> correct_uppercase_characters()
    |> String.to_atom()
  end

  @spec correct_uppercase_characters(String.t()) :: String.t()
  defp correct_uppercase_characters(string) do
    string
    |> String.split("", trim: true)
    |> Enum.map(fn char ->
      cond do
        char =~ ~r/[A-Z]+/ ->
          "_" <> String.downcase(char)

        true ->
          char
      end
    end)
    |> Enum.join()
  end

  @spec twitter_date_to_iso8601(String.t()) :: DateTime.t()
  defp twitter_date_to_iso8601(date_time) do
    year = String.slice(date_time, -4, 4)
    month = String.slice(date_time, 4, 3) |> month()
    day = String.slice(date_time, 8, 2) |> String.trim()
    time = String.slice(date_time, -19, 8)

    from_iso_trunc("#{year}-#{month}-#{day}T#{time}Z")
  end

  @spec month(String.t()) :: number()
  defp month(string) do
    # ! NOTE: I could not find any documentation (thanks twitter!) about how they abbreviate months
    # ! i need the abbreviates to convert to iso8601 to use as a date time, so that I can sort by date of publication
    # ! let's hope i guessed the abbreviates correctly
    months = %{
      "Jan" => "01",
      "Feb" => "02",
      "Mar" => "03",
      "Apr" => "04",
      "May" => "05",
      "Jun" => "06",
      "Jul" => "07",
      "Aug" => "08",
      "Sep" => "09",
      "Oct" => "10",
      "Nov" => "11",
      "Dec" => "12"
    }

    Access.get(months, string)
  end

  @spec from_iso_trunc(String.t()) :: DateTime.t()
  defp from_iso_trunc(date_time) do
    {:ok, result, _} = DateTime.from_iso8601(date_time)
    DateTime.truncate(result, :second)
  end
end
