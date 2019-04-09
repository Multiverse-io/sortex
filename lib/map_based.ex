defmodule Sorter.MapBased do
  import Ecto.Query
  alias Sorter.Order

  def sort(query, field_name, direction, assocs) do
    field = field_to_atom!(field_name, query)
    field_source = field_source(query, field_name, assocs)
    do_sort(field_source, field, query, direction)
  end

  defp field_source(query, field_name, _assocs = nil) do
    case field_name in select_fields_as_strings(query) do
      true ->
        :from_base_table

      false ->
        raise ~s|field "#{field_name}" does not exist in select fields for query "#{
                inspect(query)
              }"|
    end
  end

  defp field_source(query, _, related_table) do
    {:from_join, table_join_index(query, related_table)}
  end

  defp table_join_index(query, related_table) do
    [{_, matching_join_index}] =
      query.joins
      |> Enum.with_index()
      |> Enum.filter(fn {from_join, _} -> match?({^related_table, nil}, from_join.source) end)

    matching_join_index
  end

  defp field_to_atom!(field_name, query) do
    fields =
      query
      |> select_fields!()
      |> Keyword.values()
      |> Enum.map(fn {{_, _, [_, underlying_field_name]}, _, _} ->
        Atom.to_string(underlying_field_name)
      end)

    if field_name in fields do
      String.to_atom(field_name)
    else
      raise ~s|No field on map or joined tables for field: #{field_name} in query: #{
              inspect(query)
            }|
    end
  end

  defp select_fields!(%{select: %{expr: {_, _, fields}}}), do: fields
  defp select_fields!(query), do: raise("No select clause found in query: #{inspect(query)}")

  defp select_fields_as_strings(query) do
    query
    |> select_fields!()
    |> Keyword.keys()
    |> Enum.map(&Atom.to_string/1)
  end

  defp do_sort(:from_base_table, field, query, direction) do
    order_by(query, [x], [{^direction, ^field}])
  end

  defp do_sort({:from_join, join_index}, field, query, direction) do
    binding_index = join_index + 1
    Order.by(query, binding_index, direction, field)
  end
end
