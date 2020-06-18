defmodule ProtestArchive.Collect do
  alias ProtestArchive.CollectWorker

  def child_spec(_) do
    IO.inspect("Starting collect worker pool")

    :poolboy.child_spec(__MODULE__,
      name: {:local, __MODULE__},
      worker_module: CollectWorker,
      size: 5
    )
  end

  def get({type, tag}, num_results \\ 20, from \\ nil) do
    :poolboy.transaction(__MODULE__, fn worker_pid -> CollectWorker.get(worker_pid, {type, tag}, num_results, from) end)
  end
end
