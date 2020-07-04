defmodule ProtestArchive.CollectWorker do
  alias ProtestArchive.{CollectHelper, DatabaseWorker, Cache}

  @doc """
  get_and_save_to_db queries the specified (By the type param) api, decodes and handles the response,
  saves that data to the database and returns the data
  """
  @spec get_and_save_to_db(atom, String.t(), number | String.t(), String.t() | nil) :: list(map)
  def get_and_save_to_db(type, tag, num_results \\ 20, from \\ "recent") do
    data = CollectHelper.get_data!({type, tag}, num_results, from)
    DatabaseWorker.insert(type, data)
    data
  end

  @spec get_and_save_to_cache(atom, String.t(), number | String.t(), String.t() | nil) :: list(map)
  def get_and_save_to_cache(type, tag, num_results \\ 20, from \\ "recent") do
    data = CollectHelper.get_data!({type, tag}, num_results, from)
    Cache.put({type, tag}, data)
    data
  end

  @spec get_and_save_to_db_and_cache(atom, String.t(), number | String.t(), String.t() | nil) :: list(map)
  def get_and_save_to_db_and_cache(type, tag, num_results \\ 20, from \\ "recent") do
    data = CollectHelper.get_data!({type, tag}, num_results, from)
    Cache.put({type, tag}, data)
    DatabaseWorker.insert(type, data)
    data
  end
end
