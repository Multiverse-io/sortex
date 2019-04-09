defmodule Sorter.BindingTest do
  use ExUnit.Case, async: true
  import Ecto.Query
  alias Sorter.SchemaBased.{Accomodation, Animal, Bindings, Feed, Supplier, Storage}

  test "no bindings" do
    assert [] == Bindings.all(Animal)
  end

  test "one join with assoc" do
    assert [{Animal, Feed}] == Bindings.all(from a in Animal, join: f in assoc(a, :feed))
  end

  test "one join with schema" do
    assert [{Animal, Feed}] ==
             Bindings.all(from a in Animal, join: f in Feed, on: f.id == a.feed_id)
  end

  test "one join with table name" do
    assert [{Animal, Feed}] ==
             Bindings.all(from a in Animal, join: f in "feed", on: f.id == a.feed_id)
  end

  describe "nested_joins" do
    test "simple nested joins" do
      assert [
               {Animal, Feed},
               {Feed, Supplier}
             ] ==
               Bindings.all(
                 from a in Animal,
                   join: f in assoc(a, :feed),
                   join: fs in assoc(f, :supplier)
               )
    end

    test "nested with sibling joins" do
      assert [
               {Animal, Feed},
               {Feed, Supplier},
               {Feed, Storage},
               {Animal, Accomodation}
             ] ==
               Bindings.all(
                 from a in Animal,
                   join: f in assoc(a, :feed),
                   join: fs in assoc(f, :supplier),
                   join: s in assoc(f, :storage),
                   join: acc in assoc(a, :accomodation)
               )
    end

    test "with schemas" do
      assert [
               {Animal, Feed},
               {Feed, Supplier}
             ] ==
               Bindings.all(
                 from a in Animal,
                   join: f in Feed,
                   on: a.feed_id == f.id,
                   join: fs in Supplier,
                   on: f.supplier_id == fs.id
               )
    end

    test "mixed join types - with multiple joins between the same tables" do
      assert [
               {Animal, Feed},
               {Animal, Accomodation},
               {Feed, Supplier},
               {Feed, Storage},
               {Animal, Feed},
               {Feed, Supplier}
             ] ==
               Bindings.all(
                 from a in Animal,
                   join: f in assoc(a, :feed),
                   join: acc in "accomodation",
                   on: acc.id == a.accomodation_id,
                   join: fs in Supplier,
                   on: f.supplier_id == fs.id,
                   join: s in assoc(f, :storage),
                   join: f1 in assoc(a, :feed),
                   join: fs1 in Supplier,
                   on: f1.supplier_id == fs1.id
               )
    end
  end
end
