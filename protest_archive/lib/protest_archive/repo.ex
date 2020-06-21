defmodule ProtestArchive.Repo do
  use Ecto.Repo,
    otp_app: :protest_archive,
    adapter: Ecto.Adapters.Postgres
end
