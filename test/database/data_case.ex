defmodule Sortex.DataCase do
  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox

  using do
    quote do
      alias Sortex.Repo

      import Sortex.DataCase
    end
  end

  setup tags do
    :ok = Sandbox.checkout(Sortex.Repo)

    unless tags[:async] do
      Sandbox.mode(Sortex.Repo, {:shared, self()})
    end

    :ok
  end
end
