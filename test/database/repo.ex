defmodule Sorter.Repo do
  use Ecto.Repo,
    otp_app: :sorter,
    adapter: Ecto.Adapters.Postgres
end
