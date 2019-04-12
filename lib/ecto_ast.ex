defmodule Sortex.EctoAST do
  @underscored_binding {:_, [], Elixir}
  @bound_binding {:p, [], Elixir}

  def bindings(index) do
    if index == 0 do
      [@bound_binding]
    else
      1..index
      |> Enum.reduce([@bound_binding], fn _, acc ->
        [@underscored_binding | acc]
      end)
    end
  end
end
