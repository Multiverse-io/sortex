defmodule SorterTest do
  import Ecto.Query
  use Sorter.DataCase, async: true
  alias Sorter.{Repo}

  alias Sorter.SchemaBased.Animal
  alias Sorter.AnimalFactory

  @query from(a in Animal)

  test "does not sort if no params provided" do
    assert @query == Sorter.sort(@query, %{})
  end

  test "allows default sort" do
    query =
      Sorter.sort(@query, %{}, %{
        "sort" => %{
          "field" => "number_of_legs",
          "direction" => "asc"
        }
      })

    assert inspect(query) =~ "[asc: a0.number_of_legs]"
  end

  test "sorts according to parameters" do
    query =
      Sorter.sort(@query, %{
        "sort" => %{
          "field" => "number_of_legs",
          "direction" => "asc"
        }
      })

    assert inspect(query) =~ "[asc: a0.number_of_legs]"
  end

  test "sorts by an assoc field" do
    query =
      Sorter.sort(@query, %{
        "sort" => %{
          "assoc" => "feed",
          "field" => "type",
          "direction" => "desc"
        }
      })

    assert inspect(query) =~ "[desc: f1.type]"
  end

  test "allows a reversed sort" do
    query =
      Sorter.sort(@query, %{
        "sort" => %{
          "field" => "number_of_legs",
          "direction" => "desc",
          "reverse" => "true"
        }
      })

    assert inspect(query) =~ "[asc: a0.number_of_legs]"
  end

  test "allows a random sort" do
    query = Sorter.sort(@query, %{"sort" => %{"field" => "random"}})
    assert inspect(query) =~ "[asc: fragment(\"RANDOM()\")]"
  end

  describe "database tests" do
    test "sort by associated field " do
      AnimalFactory.insert(2, "typeb")
      AnimalFactory.insert(4, "typea")

      assert [%{feed: %{type: "typea"}}, %{feed: %{type: "typeb"}}] =
        Animal
        |> Sorter.sort(%{
          "sort" => %{
            "field" => "type",
            "assoc" => "feed",
            "direction" => "asc"
          }
        })
        |> Repo.all()
        |> Repo.preload(:feed)
    end

    test "sort by nested_association for schema based query " do
      AnimalFactory.insert(2, "grass", 30, "supplierB")
      AnimalFactory.insert(4, "grass", 30, "supplierA")

      assert [%{feed: %{supplier: %{name: "A"}}}, %{feed: %{supplier: %{name: "B"}}}]
      Animal
      |> Sorter.sort(%{
        "sort" => %{
          "field" => "name",
          "assoc" => ["feed", "supplier"],
          "direction" => "asc"
        }
      })
      |> Repo.all()
      |> Repo.preload(feed: :supplier)
    end


    @map_based_query_with_multiple_nested_joins from a in "animals",
    join: f in "feed",
    on: f.id == a.feed_id,
    join: s in "suppliers",
    on: f.supplier_id == s.id,
    select: %{supplier_name: s.name}

    test "sort by nested_association for map based query " do
      AnimalFactory.insert(4, "grass", 30, "B")
      AnimalFactory.insert(4, "grass", 30, "A")

      assert [
        %{supplier_name: "A"},
        %{supplier_name: "B"}
      ] =
        @map_based_query_with_multiple_nested_joins
        |> Sorter.sort(%{
          "sort" => %{
            "field" => "name",
            "assoc" => "suppliers",
            "direction" => "asc"
          }
        })
        |> Repo.all()
    end

    @map_based_query_with_sibling_joins from a in "animals",
    join: f in "feed",
    on: f.id == a.feed_id,
    join: acc in "accomodation",
    on: a.accomodation_id == acc.id,
    select: %{accomodation_name: acc.name}


    test "sort by associated field for query with existing joins " do
      AnimalFactory.insert(4, "grass", 30, "supplier", "B")
      AnimalFactory.insert(4, "grass", 30, "supplier", "A")

      assert [%{accomodation_name: "A"}, %{accomodation_name: "B"}] =
        @map_based_query_with_sibling_joins
        |> Sorter.sort(%{
          "sort" => %{
            "field" => "name",
            "assoc" => "accomodation",
            "direction" => "asc"
          }
        })
        |> Repo.all()
    end
  end
end
