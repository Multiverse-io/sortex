use Mix.Config
config :sorter,
  ecto_repos: [Sorter.Repo]

config :sorter, Sorter.Repo,
  username: "postgres",
  password: "postgres",
  database: "sorter_test",
  hostname: System.get_env("PGHOST") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
