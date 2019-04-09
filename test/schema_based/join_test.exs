defmodule Sorter.SchemaBased.JoinTest do
  use ExUnit.Case, async: true
  alias Sorter.SchemaBased.Join
  import Ecto.Query

  alias Sorter.SchemaBased.{Animal, Feed}

  @query from(a in Animal)
  test "creates join on base table" do
    query_text =
      @query
      |> Join.on(0, :feed)
      |> inspect()

    assert query_text =~ "join: f1 in assoc(a0, :feed)"
  end

  test "creates 100 heads which join with the correct parameters" do
    query = join(@query, :inner, [a], f in Feed, on: a.feed_id == f.id)

    1..99
    |> Enum.reduce(query, fn join_index, query ->
      query = Join.on(query, join_index, :feed)

      assert inspect(query, limit: :infinity) =~
               "join: f#{join_index + 1} in assoc(f#{join_index}, :feed)"

      query
    end)
  end
end
