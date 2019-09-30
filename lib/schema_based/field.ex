defmodule Sortex.SchemaBased.Field do
  def to_atom_if_present_on_struct!(struct, field) do
    case field in struct_fields(struct) do
      true -> struct
      false -> raise ~s|associated field <#{field}> not found on schema <#{struct.__struct__}>|
    end
    field
  end

  defp struct_fields(struct) do
    struct
    |> Map.keys()
  end
end
