defmodule Sortex.SortViewTest do
  use ExUnit.Case, async: true
  alias Sortex.SortView

  describe "sorted_column/2" do
    test "creates a link to the route provided" do
      assert SortView.sorted_column(%{query_params: %{}}, %{helper: :test, field: :any_field})
             |> elem(1)
             |> attribute_in_tag?("a", "href", RouteHelpers.route())
    end

    test "uses the field name humanized for the anchor text" do
      assert SortView.sorted_column(%{query_params: %{}}, %{helper: :test, field: :any_field})
             |> elem(1)
             |> tag_has_value?("a", "Any field")
    end
  end

  def attribute_in_tag?(markup = {:safe, _}, tag_name, attribute_name, attribute_value) do
    attribute_in_tag?(
      Phoenix.HTML.safe_to_string(markup),
      tag_name,
      attribute_name,
      attribute_value
    )
  end

  def attribute_in_tag?(markup, tag_name, attribute_name, attribute_value) do
    escaped_attribute_value = Regex.escape(attribute_value)
    Regex.match?(~r/<#{tag_name}[^>]*#{attribute_name}=\"#{escaped_attribute_value}\".*>/, markup)
  end

  def tag_has_value?(markup, tag_name, value) do
    escaped_value = Regex.escape(value)
    Regex.match?(~r/<#{tag_name}.*>#{escaped_value}<\/#{tag_name}>/, markup)
  end
end
