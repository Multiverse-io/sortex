defmodule Sorter.SchemaBased.Supplier do
  use Ecto.Schema
  import Ecto.Changeset

  schema "suppliers" do
    field :name, :string
  end

  def changeset(supplier, attrs) do
    supplier
    |> cast(attrs, [:name])
  end
end
