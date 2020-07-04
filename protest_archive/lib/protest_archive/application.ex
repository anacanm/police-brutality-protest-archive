defmodule ProtestArchive.Application do
  use Application

  def start(_type, _args) do
    children = [
      ProtestArchive.ProcessRegistry,
      ProtestArchive.Repo,
      {Task.Supervisor, name: ProtestArchive.TaskSupervisor},
      ProtestArchive.CacheSupervisor
    ]

    options = [strategy: :one_for_one]
    Supervisor.start_link(children, options)
  end
end
