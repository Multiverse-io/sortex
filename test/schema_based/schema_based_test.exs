defmodule Sorter.SchemaBasedTest do
  use ExUnit.Case, async: true
  import Ecto.Query

  alias Sorter.SchemaBased
  alias Sorter.SchemaBased.{Accomodation, Animal, Feed, Supplier}

  describe "sort" do
    test "can sort based on field on base schema" do
      sorted_query = SchemaBased.sort(Animal, "number_of_legs", :asc, nil)
      assert "#{inspect(sorted_query)}" =~ "order_by: [asc: a0.number_of_legs]"
    end

    test "can sort based on field on assoc" do
      sorted_query = SchemaBased.sort(Animal, "type", :asc, "feed")
      assert "#{inspect(sorted_query)}" =~ "order_by: [asc: f1.type]"
    end

    test "can sort based on field on nested assocs" do
      sorted_query = SchemaBased.sort(Animal, "name", :asc, ["feed", "supplier"])
      assert "#{inspect(sorted_query)}" =~ "order_by: [asc: s2.name]"
    end

    test "can sort queryables based on schema" do
      sorted_query = SchemaBased.sort(from(a in Animal), "name", :asc, ["feed", "supplier"])

      assert "#{inspect(sorted_query)}" =~ "order_by: [asc: s2.name]"
    end

    test "sorts if binding to sort by is not the last" do
      initial_query =
        from(a in Animal,
          join: f in Feed,
          on: a.feed_id == f.id,
          join: s in Supplier,
          on: f.supplier_id == s.id
        )

      sorted_query = SchemaBased.sort(initial_query, "type", :asc, ["feed"])
      assert inspect(sorted_query) =~ "order_by: [asc: f1.type]"
    end

    test "can order by correct join if nested joins have siblings" do
      initial_query =
        from(a in Animal,
          join: acc in assoc(a, :accomodation),
          join: f in assoc(a, :feed),
          join: s in assoc(f, :storage),
          join: s in assoc(f, :supplier)
        )

      sorted_query = SchemaBased.sort(initial_query, "name", :asc, ["feed", "supplier"])

      assert inspect(sorted_query) =~ "order_by: [asc: s4.name]"
    end

    test "Can order by correct join if siblings off base table" do
      initial_query =
        from(a in Animal,
          join: acc in assoc(a, :accomodation),
          join: f in assoc(a, :feed)
        )

      sorted_query = SchemaBased.sort(initial_query, "type", :asc, ["feed"])

      assert inspect(sorted_query) =~ "order_by: [asc: f2.type]"
    end
  end

  describe "joins" do
    test "don't add joins if they already exist as schema based joins" do
      initial_query = from(a in Animal, join: f in Feed, on: a.feed_id == f.id)
      assert Enum.count(initial_query.joins) == 1

      sorted_query = SchemaBased.sort(initial_query, "type", :asc, ["feed"])
      assert Enum.count(sorted_query.joins) == 1
    end

    test "don't add joins if they already exist as table based joins" do
      initial_query = from(a in Animal, join: f in "feed", on: a.feed_id == f.id)
      assert Enum.count(initial_query.joins) == 1

      sorted_query = SchemaBased.sort(initial_query, "type", :asc, ["feed"])
      assert Enum.count(sorted_query.joins) == 1
    end

    test "don't add joins if they already exist as in_assoc based joins" do
      initial_query = from(a in Animal, join: f in assoc(a, :feed))
      assert Enum.count(initial_query.joins) == 1

      sorted_query = SchemaBased.sort(initial_query, "type", :asc, ["feed"])
      assert Enum.count(sorted_query.joins) == 1
    end

    test "can add joins to the correct binding if there are intermediate joins" do
      initial_query = from(a in Animal, join: f in Feed, on: a.feed_id == f.id)

      sorted_query = SchemaBased.sort(initial_query, "name", :asc, ["accomodation"])
      assert inspect(sorted_query) =~ "join: a2 in assoc(a0, :accomodation)"
    end

    test "can add multiple joins to the correct binding if there are intermediate joins" do
      initial_query = from(a in Animal, join: ac in Accomodation, on: a.accomodation_id == ac.id)

      sorted_query = SchemaBased.sort(initial_query, "name", :asc, ["feed", "supplier"])
      assert inspect(sorted_query) =~ "join: f2 in assoc(a0, :feed)"
      assert inspect(sorted_query) =~ "join: s3 in assoc(f2, :supplier)"
    end

    test "don't add joins if joins below the first join exist" do
      initial_query =
        from(a in Animal,
          join: f in assoc(a, :feed),
          join: s in assoc(f, :supplier)
        )

      assert Enum.count(initial_query.joins) == 2

      sorted_query = SchemaBased.sort(initial_query, "name", :asc, ["feed", "supplier"])
      assert inspect(sorted_query) =~ "order_by: [asc: s2.name]"
      assert Enum.count(sorted_query.joins) == 2
    end
  end
end
