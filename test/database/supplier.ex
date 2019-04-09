defmodule Sorter.SchemaBased.Supplier do
  use Ecto.Schema

  schema "suppliers" do
    field :name, :string
  end
end
