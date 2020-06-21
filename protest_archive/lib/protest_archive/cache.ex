defmodule ProtestArchive.Cache do
  use GenServer, restart: :transient
  alias ProtestArchive.ProcessRegistry

  def start_link(name = {type, tag}) do
    IO.inspect("Starting cache: type: #{type} tag: #{tag}")
    GenServer.start_link(__MODULE__, [], name: via_tuple(name))
  end

  def get(server) do
    GenServer.call(via_tuple(server), :get)
  end

  def put(server, new_state) do
    GenServer.cast(via_tuple(server), {:put, new_state})
  end

  # Server

  @impl true
  def init(state \\ []) do
    # TODO: on init, send message to self to read from DB or query api
    {:ok, state}
  end

  @impl true
  def handle_call(:get, _from, state) do
    # TODO: if state == [], query from DB. if DB is empty, query api
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:put, new_state}, state) do
    # if the new state is not good, preserve the old state
    {:noreply, new_state || state}
  end

  ##########################
  defp via_tuple({type, tag}) do
    ProcessRegistry.via_tuple({type, tag})
  end
end
