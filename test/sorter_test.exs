defmodule SorterTest do
  import Ecto.Query
  use ExUnit.Case
  alias Sorter.{Repo}

  alias Sorter.SchemaBased.{Accomodation, Animal, Feed, Supplier}
  alias Sorter.AnimalFactory

  @query from(a in Animal)

  describe "sort/2" do
    test "does not sort if no params provided" do
      assert @query == Sorter.sort(@query, %{})
    end

    test "allows default sort" do
      query =
        Sorter.sort(@query, %{}, %{
          "sort" => %{
            "field" => "job_title",
            "direction" => "asc"
          }
        })

      assert inspect(query) =~ "[asc: r0.job_title]"
    end

    test "sorts according to parameters" do
      query =
        Sorter.sort(@query, %{
          "sort" => %{
            "field" => "job_title",
            "direction" => "asc"
          }
        })

      assert inspect(query) =~ "[asc: r0.job_title]"

      query =
        Sorter.sort(@query, %{
          "sort" => %{
            "field" => "salary",
            "direction" => "desc"
          }
        })

      assert inspect(query) =~ "[desc: r0.salary]"

      query =
        Sorter.sort(@query, %{
          "sort" => %{
            "assoc" => "company",
            "field" => "name",
            "direction" => "desc"
          }
        })

      assert inspect(query) =~ "[desc: c1.name]"
    end

    test "allows a reversed sort" do
      query =
        Sorter.sort(@query, %{
          "sort" => %{
            "field" => "job_title",
            "direction" => "desc",
            "reverse" => "true"
          }
        })

      assert inspect(query) =~ "[asc: r0.job_title]"
    end

    test "allows a random sort" do
      query = Sorter.sort(@query, %{"sort" => %{"field" => "random"}})
      assert inspect(query) =~ "[asc: fragment(\"RANDOM()\")]"
    end

    test "sort by associated field database test" do

      AnimalFactory.animal(%{number_of_legs: 4, feed: %{type: "typeb"}})
      AnimalFactory.animal(%{number_of_legs: 4, feed: %{type: "typea"}})

      assert [%{type: "typea"}, %{job_title: "typeb"}] =
               Animal
               |> Sorter.sort(%{
                 "sort" => %{
                   "field" => "type",
                   "assoc" => "feed",
                   "direction" => "desc"
                 }
               })
               |> Repo.all()
    end

    test "sort by nested_association for schema based query database test" do
      manager_a_id = ManagerFactory.new(%{user: %{email: "manager_a@whitehat.org.uk"}})
      manager_b_id = ManagerFactory.new(%{user: %{email: "manager_b@whitehat.org.uk"}})
      manager_c_id = ManagerFactory.new(%{user: %{email: "manager_c@whitehat.org.uk"}})

      RoleFactory.insert_with_company(%{job_title: "jobc"}, %{
        manager_id: manager_c_id,
        name: "companya"
      })

      RoleFactory.insert_with_company(%{job_title: "joba"}, %{
        manager_id: manager_a_id,
        name: "companyb"
      })

      RoleFactory.insert_with_company(%{job_title: "jobb"}, %{
        manager_id: manager_b_id,
        name: "companyc"
      })

      assert [%{job_title: "joba"}, %{job_title: "jobb"}, %{job_title: "jobc"}] =
               Role
               |> Sorter.sort(%{
                 "sort" => %{
                   "field" => "email",
                   "assoc" => ["company", "manager", "user"],
                   "direction" => "asc"
                 }
               })
               |> Repo.all()
    end

    @map_based_query_with_multiple_joins from r in "roles",
                                           join: c in "companies",
                                           on: r.company_id == c.id,
                                           join: m in "managers",
                                           on: m.id == c.manager_id,
                                           join: u in "users",
                                           on: u.id == m.user_id,
                                           select: %{email: u.email}

    test "sort by nested_association for map based query database test" do
      manager_a_id = ManagerFactory.new(%{user: %{email: "manager_a@whitehat.org.uk"}})
      manager_b_id = ManagerFactory.new(%{user: %{email: "manager_b@whitehat.org.uk"}})
      manager_c_id = ManagerFactory.new(%{user: %{email: "manager_c@whitehat.org.uk"}})

      RoleFactory.insert_with_company(%{job_title: "jobc"}, %{
        manager_id: manager_c_id,
        name: "companya"
      })

      RoleFactory.insert_with_company(%{job_title: "joba"}, %{
        manager_id: manager_a_id,
        name: "companyb"
      })

      RoleFactory.insert_with_company(%{job_title: "jobb"}, %{
        manager_id: manager_b_id,
        name: "companyc"
      })

      assert [
               %{email: "manager_a@whitehat.org.uk"},
               %{email: "manager_b@whitehat.org.uk"},
               %{email: "manager_c@whitehat.org.uk"}
             ] =
               @map_based_query_with_multiple_joins
               |> Sorter.sort(%{
                 "sort" => %{
                   "field" => "email",
                   "assoc" => "users",
                   "direction" => "asc"
                 }
               })
               |> Repo.all()
    end

    @map_based_query_with_join from r in "roles",
                                 join: c in "companies",
                                 on: r.company_id == c.id,
                                 left_join: m in "matches",
                                 on: r.id == m.role_id,
                                 select: %{id: r.id, job_title: r.job_title, company_name: c.name}

    test "sort by associated field for query with multiple joins database test" do
      RoleFactory.insert_with_company(%{job_title: "jobb"}, %{name: "companya"})
      RoleFactory.insert_with_company(%{job_title: "joba"}, %{name: "companyb"})

      assert [%{job_title: "joba"}, %{job_title: "jobb"}] =
               @map_based_query_with_join
               |> Sorter.sort(%{
                 "sort" => %{
                   "field" => "name",
                   "assoc" => "companies",
                   "direction" => "desc"
                 }
               })
               |> Repo.all()
    end
  end
end
