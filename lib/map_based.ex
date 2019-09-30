defmodule Sortex.MapBased do
  import Ecto.Query
  alias Sortex.Order

  def sort(query, field_name, direction, assocs) do
    field = String.to_existing_atom(field_name)
    field_source = field_source(query, field, assocs)
    do_sort(field_source, field, query, direction)
  end

  defp field_source(_, _, _assocs = nil), do: :from_base_table

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

  defp do_sort(:from_base_table, field, query, direction) do
    order_by(query, [x], [{^direction, ^field}])
  end

  defp do_sort({:from_join, join_index}, field, query, direction) do
    binding_index = join_index + 1
    Order.by(query, binding_index, direction, field)
  end
end
