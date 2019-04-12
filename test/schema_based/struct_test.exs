defmodule Sortex.StructTest do
  use ExUnit.Case, async: true
  import Ecto.Query
  alias Sortex.SchemaBased.{Animal, Feed, Struct}

  describe "from_query/1" do
    test "struct based" do
      assert %Animal{} == Struct.from_query(Animal)
    end

    test "query based" do
      assert %Animal{} == Struct.from_query(from(a in Animal))
    end
  end

  describe "assoc_module!/2" do
    test "can get the module name for an assoc" do
      assert Feed == Struct.assoc_module!(%Animal{}, :feed)
    end

    test "raises if assoc does not exist" do
      error =
        assert_raise(RuntimeError, fn -> Struct.assoc_module!(%Animal{}, :preferred_climate) end)

      assert ~s|schema <#{Animal}> does not have field <preferred_climate>| == error.message
    end

    test "raises if given assoc exists but as a different type" do
      error =
        assert_raise(RuntimeError, fn -> Struct.assoc_module!(%Animal{}, :number_of_legs) end)

      assert ~s|field <number_of_legs> exists on schema <#{Animal}> but is type <integer>, not an association| ==
               error.message
    end
  end

  describe "assoc_field_name_for_foreign_key!/2" do
    test "raises if foreign key does not exist" do
      error =
        assert_raise(RuntimeError, fn ->
          Struct.assoc_field_name_for_foreign_key!(%Animal{}, :blood_type_id)
        end)

      assert ~s|schema <#{Animal}> does not have foreign key <blood_type_id>| == error.message
    end

    test "can get field name for foreign key" do
      assert :feed == Struct.assoc_field_name_for_foreign_key!(%Animal{}, :feed_id)
    end
  end
end
