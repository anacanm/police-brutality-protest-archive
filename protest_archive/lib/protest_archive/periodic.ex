defmodule ProtestArchive.Periodic do
  use GenServer, restart: :transient
  alias ProtestArchive.{CollectWorker, CacheSupervisor}

  def start_link(_) do
    IO.inspect("Starting periodic scheduler")
    GenServer.start_link(__MODULE__, [])
  end

  ####

  @impl true
  def init(_state) do
    # on startup, send messages that will start the collection of data in 30 minutes,
    # and then stagger collection by 15 minute intervals
    Process.send_after(self(), {:news, :cache}, :timer.minutes(30))
    Process.send_after(self(), {:tweet, :cache}, :timer.minutes(45))
    Process.send_after(self(), {:news, :db}, :timer.minutes(60))
    Process.send_after(self(), {:tweet, :db}, :timer.minutes(75))
    {:ok, []}
  end

  @impl true
  def handle_info({type, save_destination}, _state) do
    schedule_work_in_an_hour(type, save_destination)
    delegate_work(type, save_destination)
    {:noreply, []}
  end

  def delegate_work(type, :cache) do
    CacheSupervisor.tags()
    |> Enum.each(fn tag -> CollectWorker.get_and_save_to_cache(type, tag) end)
  end

  def delegate_work(type, :db) do
    CacheSupervisor.tags()
    |> Enum.each(fn tag -> CollectWorker.get_and_save_to_db(type, tag) end)
  end

  #############

  defp schedule_work_in_an_hour(type, save_destination) do
    Process.send_after(self(), {type, save_destination}, :timer.minutes(60))
  end
end
