defmodule Sorter.SchemaBased.Storage do
  use Ecto.Schema

  schema "storage" do
    field :temerature, :integer
  end
end
