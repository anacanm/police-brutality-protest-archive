import Config

config :protest_archive, ProtestArchive.Repo,
  database: "protest_archive_repo",
  username: "protest",
  password: "icantbreathe!",
  hostname: "localhost",
  migration_timestamps: [type: :timestamptz],
  port: 5432

config :protest_archive,
  news_api_key: "37f15c3973524b318a35ddb228823663",
  twitter_bearer_token: "AAAAAAAAAAAAAAAAAAAAAID6FAEAAAAAdkQYtcR7AfaVAOr1KAn4Td8mF38%3Drhg8vRoPrXEpXvFLRXNJVVqx3S8tXxBoN1XRKk30PgFZfcTeUS",
  ecto_repos: [ProtestArchive.Repo]
