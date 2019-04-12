use Mix.Config
config :sortex,
  ecto_repos: [Sortex.Repo]

config :sortex, Sortex.Repo,
  username: "postgres",
  password: "postgres",
  database: "sortex_test",
  hostname: System.get_env("PGHOST") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :sortex,
  route_helpers_module: RouteHelpers
