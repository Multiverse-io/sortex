defmodule Sorter.SchemaBased.Join do
  import Ecto.Query, only: :macros
  alias Sorter.EctoAST

  Enum.map(0..99, fn index ->
    bindings = EctoAST.bindings(index)

    def on(query, unquote(index), name_of_assoc_to_join) do
      join(query, :inner, unquote(bindings), p in assoc(p, ^name_of_assoc_to_join))
    end
  end)
end
