defmodule Sorter.SchemaBased.Storage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "storage" do
    field :temperature, :integer
  end

  def changeset(storage, attrs) do
    storage
    |> cast(attrs, [:temperature])
  end
end
