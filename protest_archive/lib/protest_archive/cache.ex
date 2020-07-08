defmodule ProtestArchive.Cache do
  use GenServer, restart: :transient
  alias ProtestArchive.{ProcessRegistry, DatabaseWorker, CollectWorker}

  def start_link(name = {type, tag}) do
    IO.inspect("Starting cache: type: #{type} tag: #{tag}")
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  @doc """
  the server param is a {type, tag} tuple
  """
  def get(server = {type, tag}) do
    GenServer.call(via_tuple(server), {:get, type, tag})
  end

  def put(server, new_state) do
    GenServer.cast(via_tuple(server), {:put, new_state})
  end

  # Server

  @impl true
  def init({type, tag}) do
    send(self(), :init_state)
    # name is used as the inital state so that when calling :init_state, it can load state with the correct values
    {:ok, {type, tag}}
  end

  @impl true
  def handle_call({:get, type, tag}, _from, state) do
    state = handle_state(type, tag, state)

    {:reply, state, state}
  end

  @impl true
  def handle_cast({:put, new_state}, state) do
    # if the new state is not good, preserve the old state
    {:noreply, new_state || state}
  end

  @impl true
  def handle_info(:init_state, _state = {type, tag}) do
    new_state = handle_state(type, tag, [])

    {:noreply, new_state}
  end

  #################################

  # if state == [], read from DB. if DB, is empty, query API
  @spec handle_state(atom, String.t(), list()) :: list(map)
  defp handle_state(type, tag, state) do
    cond do
      state != [] ->
        state

      true ->
        case DatabaseWorker.get_tag(type, tag, "published_at") do
          [] ->
            cond do
              type == :news ->
                CollectWorker.get_and_save_to_db(:news, tag, 25, nil)

              type == :tweet ->
                CollectWorker.get_and_save_to_db(:tweet, tag, 25, "recent")
            end

          new_state_from_db ->
            new_state_from_db
        end
    end
  end

  ##########################
  defp via_tuple({type, tag}) do
    ProcessRegistry.via_tuple({type, tag})
  end
end
