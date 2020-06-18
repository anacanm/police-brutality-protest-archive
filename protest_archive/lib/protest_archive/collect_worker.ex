defmodule ProtestArchive.CollectWorker do
  use GenServer, restart: :transient
  alias ProtestArchive.{CollectHelper}

  @moduledoc """
  ProtestArchive.CollectWorker provides an interface for collecting (fetching and saving to the cache and database) news and tweet data
  """

  # Client

  def start_link(_) do
    IO.puts("Starting collect worker")
    GenServer.start_link(__MODULE__, [])
  end

  def get_news(pid, queries, num_results, from) do
    GenServer.call(pid, {:get_news, queries, num_results, from})
  end

  # Server

  @impl true
  def init(state \\ []) do
    {:ok, state}
  end

  @impl true
  def handle_call({:get_news, queries, num_results, from}, _from, _state) do
    data = CollectHelper.get_data!(queries, num_results, from)
    {:reply, data, data}
  end
end
