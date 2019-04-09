Sorter.Repo.start_link()
ExUnit.start()
:ok = Ecto.Adapters.SQL.Sandbox.checkout(Sorter.Repo)
Ecto.Adapters.SQL.Sandbox.mode(Sorter.Repo, {:shared, self()})
