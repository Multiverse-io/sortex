defmodule Sortex.SchemaBased.Accomodation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "accomodation" do
    field :name, :string
  end

  def changeset(accomodation, attrs) do
    accomodation
    |> cast(attrs, [:name])
  end
end
