defmodule Sortex.SchemaBased.Animal do
  use Ecto.Schema
  alias Sortex.SchemaBased.{Accomodation, Feed}
  import Ecto.Changeset

  schema "animals" do
    field :number_of_legs, :integer
    belongs_to :feed, Feed
    belongs_to :accomodation, Accomodation
  end

  def changeset(animal, attrs) do
    animal
    |> cast(attrs, [:number_of_legs])
    |> cast_assoc(:feed)
    |> cast_assoc(:accomodation)
  end
end
