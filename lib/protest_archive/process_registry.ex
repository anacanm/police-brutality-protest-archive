defmodule ProtestArchive.ProcessRegistry do
  def start_link do
    IO.inspect("Starting process registry")
    Registry.start_link(keys: :unique, name: __MODULE__)
  end

  def via_tuple({type, tag}) do
    {:via, Registry, {__MODULE__, {type, tag}}}
  end

  def child_spec(_) do
    # override the Registry child spec
    Supervisor.child_spec(
      Registry,
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    )
  end
end
