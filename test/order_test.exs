defmodule Sortex.OrderTest do
  use ExUnit.Case, async: true
  alias Sortex.Order
  import Ecto.Query

  @query from(a in "animals")
  @base_table_binding_index 0

  test "can add order_by on base table" do
    query_text =
      @query
      |> Order.by(@base_table_binding_index, :asc, :type)
      |> inspect(limit: :infinity)

    assert query_text =~ "order_by: [asc: a#{@base_table_binding_index}.type]"
  end

  test "can add order by up to the 99th join" do
    join_index_range = 1..99

    query =
      Enum.reduce(join_index_range, @query, fn _, query ->
        join(query, :inner, [a], f in "feed", on: a.feed_id == f.id)
      end)

    join_index_range
    |> Enum.each(fn join_index ->
      query = Order.by(query, join_index, :asc, :type)
      assert inspect(query, limit: :infinity) =~ "order_by: [asc: f#{join_index}.type]"
    end)
  end
end
