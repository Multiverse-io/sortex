defmodule Sorter.Order do
  import Ecto.Query
  alias Sorter.EctoAST

  Enum.map(0..99, fn index ->
    bindings = EctoAST.bindings(index)

    def by(query, unquote(index), direction, field) do
      order_by(query, unquote(bindings), [{^direction, field(p, ^field)}])
    end
  end)
end
