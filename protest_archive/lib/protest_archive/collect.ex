defmodule ProtestArchive.Collect do
  @moduledoc """
  ProtestArchive.Collect provides an interface for collecting (fetching and saving to the cache and database) news and tweet data
  """
  def get_data!(queries, num_results \\ 20, from \\ nil) when is_list(queries) do
    url(queries, num_results, from)
    |> fetch_data!()
  end

  #############################################
  defp fetch_data!(url) when is_bitstring(url) do
    url
    |> HTTPoison.get!()
  end

  defp url(queries, num_results, _from = nil) when is_list(queries) do
    # allow the news api to calculate oldest date if no from date is provided
    "https://newsapi.org/v2/everything?q=#{encode_queries(queries)}&pageSize=#{num_results}&language=en&apiKey=#{
      Application.fetch_env!(:protest_archive, :news_api_key)
    }"
  end

  defp url(queries, num_results, from) when is_list(queries) do
    "https://newsapi.org/v2/everything?q=#{encode_queries(queries)}&pageSize=#{num_results}&from=#{from}&language=en&apiKey=#{
      Application.fetch_env!(:protest_archive, :news_api_key)
    }"
  end

  defp encode_queries([head | tail], operator \\ "AND") do
    operator = String.upcase(operator)

    [head | Enum.map(tail, fn query -> " #{operator} " <> String.trim(query) end)]
    |> Enum.join()
    |> URI.encode()
  end
end
