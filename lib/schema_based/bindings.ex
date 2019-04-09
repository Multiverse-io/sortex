defmodule Sorter.SchemaBased.Bindings do
  alias Sorter.SchemaBased.Struct

  def all(%{joins: joins} = query) do
    {bindings, _} =
      joins
      # offset 1 to make the index the correct binding index... joins list does not include the base table which is always at 0
      |> Enum.with_index(_offset = 1)
      |> Enum.reduce({[], []}, &join_to_module(&1, &2, query))

    Enum.reverse(bindings)
  end

  def all(_), do: []

  defp join_to_module(
         {%{assoc: {parent_binding_index, assoc_field_name}}, binding_index},
         {bindings, lookups},
         query
       ) do
    parent_module = parent_module(parent_binding_index, query, lookups)
    assoc_module = Struct.assoc_module!(struct(parent_module), assoc_field_name)

    lookups =
      add_lookup(lookups, parent_binding_index, binding_index, assoc_field_name, assoc_module)

    {[{parent_module, assoc_module} | bindings], lookups}
  end

  defp join_to_module({a = %{source: {nil, module}}, binding_index}, {bindings, lookups}, query) do
    {parent_binding_index, parent_module, assoc_field_name} =
      parent_details(a.on.expr, query, lookups)

    lookups = add_lookup(lookups, parent_binding_index, binding_index, assoc_field_name, module)
    {[{parent_module, module} | bindings], lookups}
  end

  defp join_to_module({a = %{source: {_, nil}}, binding_index}, {bindings, lookups}, query) do
    {parent_binding_index, parent_module, assoc_field_name} =
      parent_details(a.on.expr, query, lookups)

    assoc_module = Struct.assoc_module!(struct(parent_module), assoc_field_name)

    lookups =
      add_lookup(lookups, parent_binding_index, binding_index, assoc_field_name, assoc_module)

    {[{parent_module, assoc_module} | bindings], lookups}
  end

  defp parent_details({_, _, join_expressions}, query, lookups) do
    {parent_binding_index, foreign_key} =
      join_expressions
      |> Enum.map(fn {{_, _, [{_, _, [x]}, foreign_key]}, _, _} -> {x, foreign_key} end)
      |> Enum.min_by(fn {x, _} -> x end)

    parent_module = parent_module(parent_binding_index, query, lookups)

    assoc_field_name =
      Struct.assoc_field_name_for_foreign_key!(struct(parent_module), foreign_key)

    {parent_binding_index, parent_module, assoc_field_name}
  end

  defp parent_module(parent_binding_index, query, lookups) do
    if parent_binding_index == 0 do
      Struct.from_query(query).__struct__
    else
      module(lookups, parent_binding_index)
    end
  end

  defp add_lookup(lookups, parent_binding_index, binding_index, assoc_field_name, module) do
    [
      %{
        parent_binding_index: parent_binding_index,
        binding_index: binding_index,
        assoc_field_name: assoc_field_name,
        module: module
      }
      | lookups
    ]
  end

  defp module(lookups, index) do
    [x] =
      Enum.filter(lookups, fn x ->
        x.binding_index == index
      end)

    x.module
  end
end
