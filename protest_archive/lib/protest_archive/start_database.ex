defmodule ProtestArchive.StartDatabase do
  use Agent, restart: :transient, shutdown: 5000

  def start_link(_) do
    System.cmd("mix", ["ecto.create"])
    System.cmd("mix", ["ecto.migrate"])
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end
end
