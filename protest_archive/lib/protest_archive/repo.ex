defmodule ProtestArchive.Repo do
  use Ecto.Repo,
    otp_app: :protest_archive,
    adapter: Ecto.Adapters.Postgres

  def init(_type, config) do
    IO.inspect("STARTING REPO")
    {:ok, config}
  end
end
