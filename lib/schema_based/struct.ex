defmodule Sortex.SchemaBased.Struct do
  def from_query(query) do
    case struct(query) do
      %Ecto.Query{from: %{source: {_, module}}} -> struct(module)
      %_{} = query -> query
    end
  end

  def assoc_module!(struct, assoc_name) do
    changeset = Ecto.Changeset.change(struct)

    case Map.get(changeset.types, assoc_name) do
      {:assoc, %{queryable: assoc_module}} ->
        assoc_module

      nil ->
        raise ~s|schema <#{struct.__struct__}> does not have field <#{assoc_name}>|

      type ->
        raise ~s|field <#{assoc_name}> exists on schema <#{struct.__struct__}> but is type <#{
                type
              }>, not an association|
    end
  end

  def assoc_field_name_for_foreign_key!(struct, foreign_key) do
    changeset = Ecto.Changeset.change(struct)

    changeset.types
    |> Enum.filter(fn
      {_, {:assoc, assoc}} -> assoc.owner_key == foreign_key
      _ -> false
    end)
    |> case do
      [{key, _}] -> key
      [] -> raise ~s|schema <#{struct.__struct__}> does not have foreign key <#{foreign_key}>|
    end
  end
end
