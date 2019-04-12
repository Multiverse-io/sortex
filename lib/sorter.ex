defmodule Sortex do
  import Ecto.Query, only: [order_by: 2]
  alias Sortex.MapBased
  alias Sortex.SchemaBased

  def sort(query, params, default_sort \\ %{})

  def sort(query, %{"sort" => params = %{"field" => field, "direction" => direction}}, _) do
    direction = direction(direction, Map.get(params, "reverse"))
    assoc = params |> Map.get("assoc")
    do_sort(query, field, direction, assoc)
  end

  def sort(query, %{"sort" => %{"field" => "random"}}, _) do
    order_by(query, fragment("RANDOM()"))
  end

  def sort(query, _, %{"sort" => %{"field" => _}} = default_sort) do
    sort(query, default_sort, %{})
  end

  def sort(query, _, _), do: query

  defp do_sort(%Ecto.Query{from: %{source: {_, nil}}} = query, field_name, direction, assoc) do
    MapBased.sort(query, field_name, direction, assoc)
  end

  defp do_sort(query, field_name, direction, assoc) do
    SchemaBased.sort(query, field_name, direction, assoc)
  end

  defp direction("asc", _reverse = "true"), do: :desc
  defp direction("asc", _), do: :asc
  defp direction("desc", _reverse = "true"), do: :asc
  defp direction("desc", _), do: :desc
  defp direction(_, _), do: :asc
end
