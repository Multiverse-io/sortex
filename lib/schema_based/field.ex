defmodule Sorter.SchemaBased.Field do
  def to_atom_if_present_on_struct!(_, field_name) when is_atom(field_name), do: field_name

  def to_atom_if_present_on_struct!(struct, field) do
    case field in struct_fields(struct) do
      true -> struct
      false -> raise ~s|associated field <#{field}> not found on schema <#{struct.__struct__}>|
    end

    String.to_atom(field)
  end

  defp struct_fields(struct) do
    struct
    |> Map.keys()
    |> Enum.map(&Atom.to_string/1)
  end
end
