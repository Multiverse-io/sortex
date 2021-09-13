defmodule Sortex.SortViewTest do
  use ExUnit.Case, async: true
  alias Sortex.SortView

  describe "sorted_column/2" do
    test "creates a link to the route provided" do
      assert SortView.sorted_column(%{query_params: %{}}, %{helper: :test, field: :any_field})
             |> anchor_tag()
             |> anchor_text_equals("Any field")
    end

    test "uses the field name humanized for the anchor text" do
      assert SortView.sorted_column(%{query_params: %{}}, %{helper: :test, field: :any_field})
             |> anchor_tag()
             |> anchor_text_equals("Any field")
    end

    test "can encode assocs" do
      assert [
               "test_route?sort[assoc][]=table_1&sort[assoc][]=table_2&sort[direction]=asc&sort[field]=any_field"
             ] ==
               SortView.sorted_column(
                 %{
                   query_params: %{}
                 },
                 %{
                   helper: :test,
                   field: :any_field,
                   direction: :asc,
                   assoc: [:table_1, :table_2]
                 }
               )
               |> anchor_tag()
               |> Floki.attribute("href")
    end

    test "if sort already applied for the column, reverses it" do
      assert [
               "test_route?sort[assoc][]=table_1&sort[assoc][]=table_2&sort[direction]=desc&sort[field]=any_field"
             ] ==
               SortView.sorted_column(
                 %{
                   query_params: %{
                     "sort" => %{
                       "assoc" => ["table_1", "table_2"],
                       "field" => "any_field",
                       "direction" => "asc"
                     }
                   }
                 },
                 %{
                   helper: :test,
                   field: :any_field,
                   direction: :asc,
                   assoc: [:table_1, :table_2]
                 }
               )
               |> anchor_tag()
               |> Floki.attribute("href")
    end

    test "ignores jank input" do
      assert SortView.sorted_column(
               %{query_params: %{"sort" => %{"direction" => "hasdasd", "field" => "any_field"}}},
               %{
                 helper: :test,
                 field: :any_field
               }
             )
             |> anchor_tag()
             |> anchor_text_equals("Any field")
    end
  end

  defp anchor_tag({:safe, markup}) do
    markup
    |> Floki.parse_document!()
    |> Floki.find("a")
  end

  defp anchor_text_equals(anchor_tag, expected_value) do
    assert expected_value == Floki.text(anchor_tag)
  end
end
