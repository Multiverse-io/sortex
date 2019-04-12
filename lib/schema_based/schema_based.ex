defmodule Sortex.SchemaBased do
  require Logger
  alias Sortex.SchemaBased.{Bindings, Join, RelationshipTree, Struct}
  alias Sortex.Order

  @base_table_binding_index 0

  def sort(query, sort_field, direction, assocs) do
    case assocs do
      nil -> order_by(query, sort_field, direction, [])
      [_ | _] = assocs -> order_by(query, sort_field, direction, assocs)
      assoc -> order_by(query, sort_field, direction, [assoc])
    end
  end

  defp order_by(query, sort_field, direction, assocs) do
    relationship_tree = RelationshipTree.from_parameters!(query, sort_field, assocs)

    query = add_joins(query, relationship_tree)
    order_by_binding_index = order_by_binding_index(relationship_tree, query)

    Order.by(query, order_by_binding_index, direction, String.to_atom(sort_field))
  end

  defp add_joins(query, relationship_tree) do
    Enum.reduce(relationship_tree, query, fn relationship, query ->
      bindings = Bindings.all(query)

      if has_binding?(bindings, relationship) do
        query
      else
        add_join(relationship, bindings, query)
      end
    end)
  end

  defp add_join(relationship, bindings, query) do
    base_struct = Struct.from_query(query).__struct__

    case relationship do
      {^base_struct, _, field} ->
        Join.on(query, @base_table_binding_index, field)

      {parent_module, _, field} ->
        parent_binding_index = binding_index(bindings, parent_module)
        Join.on(query, parent_binding_index, field)
    end
  end

  defp has_binding?(bindings, {_, module, _}) do
    binding_index(bindings, module) != :not_found
  end

  defp order_by_binding_index([], _), do: @base_table_binding_index

  defp order_by_binding_index(relationship_tree, query) do
    {_, last_assoc, _} = List.last(relationship_tree)

    query
    |> Bindings.all()
    |> binding_index(last_assoc)
  end

  defp binding_index(bindings, module) do
    case Enum.find_index(bindings, fn {_, join_module} -> module == join_module end) do
      nil ->
        :not_found

      index ->
        index + 1
        # We add 1 here as the bindings do not include the base table
    end
  end
end
