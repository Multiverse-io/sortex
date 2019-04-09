defmodule Sorter.AnimalFactory do
  alias Sorter.SchemaBased.Animal

  def animal(attrs) do
    Animal.changeset(%Animal{}, attrs)
  end
end
