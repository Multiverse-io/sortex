Sortex.Repo.start_link()
ExUnit.start()
:ok = Ecto.Adapters.SQL.Sandbox.checkout(Sortex.Repo)
Ecto.Adapters.SQL.Sandbox.mode(Sortex.Repo, {:shared, self()})
