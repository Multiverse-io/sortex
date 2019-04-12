defmodule RouteHelpers do
  def route, do: "test_route"

  def test(_, _, _), do: route()
end
