defmodule Sorter.SchemaBased.Feed do
  use Ecto.Schema
  import Ecto.Changeset
  alias Sorter.SchemaBased.{Supplier, Storage}

  schema "feed" do
    field :type, :string
    belongs_to :supplier, Supplier
    belongs_to :storage, Storage
  end

  def changeset(feed, attrs) do
    feed
    |> cast(attrs, [:type])
    |> cast_assoc(:supplier)
    |> cast_assoc(:storage)
  end
end
