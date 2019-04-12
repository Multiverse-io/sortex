defmodule Sortex.Repo do
  use Ecto.Repo,
    otp_app: :sortex,
    adapter: Ecto.Adapters.Postgres
end
