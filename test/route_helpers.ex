defmodule RouteHelpers do
  def route, do: "test_route"

  def test(_, _, params) do
    encoded_params = Plug.Conn.Query.encode(params)
    route() <> "?" <> encoded_params
  end
end
