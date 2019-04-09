defmodule Sorter.SchemaBased.RelationshipTree do
  alias Sorter.SchemaBased.{Field, Struct}

  def from_parameters!(query, sort_field, assocs) do
    base_struct = Struct.from_query(query)

    relationships =
      Enum.reduce(
        assocs,
        [{:root, base_struct, :no_assoc_field}],
        fn assoc_field_name, [{_, parent, _} | _] = acc ->
          assoc_struct = associated_struct!(parent, assoc_field_name)
          [{parent, assoc_struct, String.to_atom(assoc_field_name)} | acc]
        end
      )

    relationships
    |> validate_sort_field(base_struct, sort_field)
    |> Enum.reject(fn {parent, _, _} -> parent == :root end)
    |> Enum.map(fn {x, y, field_name} -> {x.__struct__, y.__struct__, field_name} end)
    |> Enum.reverse()
  end

  defp validate_sort_field(relationships = [{_, last_relation, _} | _], _, sort_field) do
    Field.to_atom_if_present_on_struct!(last_relation, sort_field)
    relationships
  end

  defp associated_struct!(struct, assoc_field_name) do
    field = Field.to_atom_if_present_on_struct!(struct, assoc_field_name)

    struct
    |> Struct.assoc_module!(field)
    |> struct()
  end
end
