defmodule Sorter.AnimalFactory do
  alias Sorter.SchemaBased.Animal
  alias Sorter.Repo

  def insert(leg_count \\4, feed_type \\ "grass", storage_temperature \\ 30, supplier_name \\ "supplier1", accomodation_name \\ "barn") do
    attrs = %{
      number_of_legs: leg_count,
      accomodation: %{
        name: accomodation_name
      },
      feed: %{
        type: feed_type,
        storage: %{
          temperature: storage_temperature
        },
        supplier: %{
          name: supplier_name
        }
      }
    }

    %Animal{}
    |> Animal.changeset(attrs)
    |> Repo.insert
  end
end
