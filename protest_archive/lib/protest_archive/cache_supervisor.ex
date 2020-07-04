defmodule ProtestArchive.CacheSupervisor do
  alias ProtestArchive.Cache

  def start_link() do
    IO.inspect("Starting cache supervisor")

    tags = ["black lives matter", "police brutality", "protest"]

    children =
      for tag <- tags, type <- [:news, :tweet] do
        Supervisor.child_spec(Cache, id: {type, tag}, start: {Cache, :start_link, [{type, tag}]})
      end

    options = [name: __MODULE__, strategy: :one_for_one]
    Supervisor.start_link(children, options)
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end
end
