defmodule ProtestArchive.CacheSupervisor do
  alias ProtestArchive.Cache

  def start_link() do
    IO.inspect("Starting cache supervisor")

    # TODO: update children to have both news and tweet tags
    children =
      Enum.map(["black lives matter", "police brutality", "protest"], fn elem ->
        Supervisor.child_spec(Cache, id: {:news, elem}, start: {Cache, :start_link, [{:news, elem}]})
      end)

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
