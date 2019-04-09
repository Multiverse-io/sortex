defmodule Sorter.MapBasedFieldsTest do
  use ExUnit.Case, async: true
  alias Sorter.MapBased
  import Ecto.Query

  test "Can sort based on field on non joined table" do
    query = from a in "animals", select: %{number_of_legs: a.number_of_legs}

    sorted_query = MapBased.sort(query, "number_of_legs", :asc, nil)

    assert "#{inspect(sorted_query)}" =~ "order_by: [asc: a0.number_of_legs]"
  end

  test "Can sort based on field on joined table" do
    query =
      from(a in "animals",
        join: f in "feed",
        on: a.feed_id == f.id,
        join: b in "bedding",
        on: a.bedding_id == b.id,
        select: %{number_of_legs: a.number_of_legs, bedding: b.type}
      )

    sorted_query = MapBased.sort(query, "type", :asc, "bedding")

    assert "#{inspect(sorted_query)}" =~ "order_by: [asc: b2.type]"
  end
end
