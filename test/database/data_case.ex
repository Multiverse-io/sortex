defmodule Sorter.DataCase do
  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox
  alias Ecto.Changeset

  using do
    quote do
      alias Sorter.Repo

      import Sorter.DataCase
    end
  end

  setup tags do
    :ok = Sandbox.checkout(Sorter.Repo)

    unless tags[:async] do
      Sandbox.mode(Sorter.Repo, {:shared, self()})
    end

    :ok
  end
end
