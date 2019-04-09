defmodule Sorter.SchemaBased.RelationshipTreeTest do
  use ExUnit.Case, async: true

  alias Sorter.SchemaBased.RelationshipTree
  alias Sorter.SchemaBased.{Animal, Feed, Supplier}

  describe "from_parameters!/3" do
    test "returns no_relationships if field is directly on base table" do
      assert [] == RelationshipTree.from_parameters!(%Animal{}, "number_of_legs", [])
    end

    test "returns tree for valid parameters" do
      assert [
               {Animal, Feed, :feed},
               {Feed, Supplier, :supplier}
             ] ==
               RelationshipTree.from_parameters!(%Animal{}, "name", [
                 "feed",
                 "supplier"
               ])
    end

    test "raises if field is not present on base struct" do
      error =
        assert_raise(RuntimeError, fn ->
          RelationshipTree.from_parameters!(%Animal{}, "tooth_size", [])
        end)

      assert ~s|associated field <tooth_size> not found on schema <#{Animal}>| == error.message
    end

    test "raises if field is not present on assoc" do
      error =
        assert_raise(RuntimeError, fn ->
          RelationshipTree.from_parameters!(%Animal{}, "number_of_biscuits", ["feed"])
        end)

      assert ~s|associated field <number_of_biscuits> not found on schema <#{Feed}>| ==
               error.message
    end

    test "raises if given assoc is not present on struct" do
      assert_raise(RuntimeError, fn ->
        RelationshipTree.from_parameters!(%Animal{}, "dont care", ["number_of_legs"])
      end)
    end
  end
end
