defmodule Sortex.SortView do
  alias Phoenix.HTML.Form

  def column_class, do: "sortex-clickable-column"

  def sorted_column(conn, opts) do
    helper_action = opts[:helper]
    action = opts[:action] || :index
    helpers_module = Application.get_env(:sortex, :route_helpers_module)

    {direction, arrow} = direction(opts, conn.query_params["sort"])

    params = params(opts, conn.query_params, direction)

    url =
      case opts[:route_params] do
        nil ->
          apply(helpers_module, helper_action, [conn, action, params])

        route_params ->
          add_params(helpers_module, conn, helper_action, action, route_params, params)
      end

    Phoenix.HTML.raw(~s(<a href="#{url}" class="#{column_class()}">#{title(opts, arrow)}</a>))
  end

  defp add_params(helpers_module, conn, helper_action, action, route_params, params)
       when is_list(route_params) do
    apply(helpers_module, helper_action, [conn, action] ++ route_params ++ [params])
  end

  defp add_params(helpers_module, conn, helper_action, action, route_params, params) do
    apply(helpers_module, helper_action, [conn, action, route_params, params])
  end

  defp params(opts, query_params, direction) do
    query_params
    |> Map.drop(["sort"])
    |> Map.merge(%{"sort" => %{"field" => opts[:field], "direction" => direction}})
    |> add_optional("assoc", opts[:assoc])
    |> add_optional("reverse", opts[:reverse])
  end

  defp add_optional(query_params, _, nil), do: query_params

  defp add_optional(query_params, option_name, option_value) do
    put_in(query_params, ["sort", option_name], option_value)
  end

  def direction(opts, %{
        "field" => field,
        "direction" => direction,
        "assoc" => current_sort_assocs
      }) do
    column_assocs = Enum.map(opts[:assoc], &to_string/1)

    if(Atom.to_string(opts[:field]) == field && column_assocs == current_sort_assocs) do
      opposite_direction(direction)
    else
      {direction, :not_sorted}
    end
  end

  def direction(opts, %{"field" => field, "direction" => direction}) do
    if(Atom.to_string(opts[:field]) == field) do
      opposite_direction(direction)
    else
      {direction, :not_sorted}
    end
  end

  def direction(_, _), do: {"asc", :not_sorted}

  defp opposite_direction("asc"), do: {"desc", "▼"}
  defp opposite_direction("desc"), do: {"asc", "▲"}
  defp opposite_direction(_), do: {"asc", :not_sorted}

  defp title(opts, :not_sorted), do: cased_title(opts)

  defp title(opts, arrow), do: "#{cased_title(opts)} #{arrow}"

  defp cased_title(opts) do
    title = opts[:title] || opts[:field]

    case is_atom(title) do
      true -> Form.humanize(title)
      false -> title
    end
  end
end
