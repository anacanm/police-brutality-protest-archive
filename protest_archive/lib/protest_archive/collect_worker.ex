defmodule ProtestArchive.CollectWorker do
  alias ProtestArchive.{CollectHelper, DatabaseWorker, Cache, CacheSupervisor}

  @doc """
  get_and_save_to_db queries the specified (By the type param) api, decodes and handles the response,
  saves that data to the database and returns the data
  """
  @spec get_and_save_to_db(atom, String.t(), number | String.t(), String.t() | nil) :: list(map)
  def get_and_save_to_db(type, tag, num_results \\ 100, from \\ "recent") do
    data = CollectHelper.get_data!({type, tag}, num_results, from)

    Task.Supervisor.start_child(ProtestArchive.TaskSupervisor, fn ->
      DatabaseWorker.insert(type, data)
    end)

    data
  end

  @spec get_and_save_to_cache(atom, String.t(), number | String.t(), String.t() | nil) :: list(map)
  def get_and_save_to_cache(type, tag, num_results \\ 25, from \\ "recent") do
    data = CollectHelper.get_data!({type, tag}, num_results, from)

    Task.Supervisor.start_child(ProtestArchive.TaskSupervisor, fn ->
      Cache.put({type, tag}, data)
    end)

    data
  end

  @spec get_and_save_to_db_and_cache(atom, String.t(), number | String.t(), String.t() | nil) :: list(map)
  def get_and_save_to_db_and_cache(type, tag, num_results \\ 100, from \\ "recent") do
    data = CollectHelper.get_data!({type, tag}, num_results, from)

    Task.Supervisor.start_child(ProtestArchive.TaskSupervisor, fn ->
      Cache.put({type, tag}, data)
      DatabaseWorker.insert(type, data)
    end)

    data
  end

  def save_to_db(type, tag, num_results \\ 100, from \\ "recent") do
    Task.Supervisor.start_child(ProtestArchive.TaskSupervisor, fn ->
      data = CollectHelper.get_data!({type, tag}, num_results, from)
      DatabaseWorker.insert(type, data)
    end)
  end

  def save_to_cache(type, tag, num_results \\ 25, from \\ "recent") do
    Task.Supervisor.start_child(ProtestArchive.TaskSupervisor, fn ->
      data = CollectHelper.get_data!({type, tag}, num_results, from)
      Cache.put({type, tag}, data)
    end)
  end

  def save_to_db_and_cache(type, tag, num_results \\ 100, from \\ "recent") do
    Task.Supervisor.start_child(ProtestArchive.TaskSupervisor, fn ->
      data = CollectHelper.get_data!({type, tag}, num_results, from)
      Cache.put({type, tag}, data)
      DatabaseWorker.insert(type, data)
    end)
  end

  @doc """
  get all from cache asynchronously reads all cache data for the specified type (:news or :tweet)
  and returns the result in a single, unsorted list
  """
  @spec get_all_from_cache(:news | :tweet) :: list(map)
  def get_all_from_cache(type) do
    # spawn task processes that collect from caches
    Enum.map(CacheSupervisor.tags(), fn tag ->
      Task.Supervisor.async(ProtestArchive.TaskSupervisor, fn ->
        Cache.get({type, tag})
      end)
    end)
    |> Enum.reduce([], fn task, acc -> Task.await(task) ++ acc end)

    # and then reduce all results into one UNSORTED list
  end
end
