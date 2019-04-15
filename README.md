# Sortex

Dynamically sort data in Elixir!

Sortex examines your ecto queries and adds the desired sorting adding any required joins dynamically.

You can use it like this:
```
  Animal
  |> Sorter.sort(%{"sort" => %{"field" => "number_of_feet"}})
  |> Repo.all
```

It also provides View functions to use in Phoenix templates to ensure the parameters are correct for the backend e.g

```
<table>
  <thead>
    <tr>
      <th><%= sorted_column @conn, helper: :animal_path, action: :show, field: :number_of_feet %></th>
    </tr>
  </thead>
  <tbody>
    <td><%= animal.number_of_feet %></td>
  </tbody>
</table>
```

It supports assoc fields on schema based queries too, but you do need to tell it the links between schema as a schema could appear more than once in a tree of nested schemas...
For example, assuming you have an `Animals` schema with a `Feed` assoc and the `Feed` assoc has a `Supplier` assoc and you wish to sort by the `name` field on the `Supplier` schema you would do this:
```
<%= sorted_column @conn, helper: :animal_path, action: :show, assoc: [:feed, :supplier] field: :name %></th>
```

If you are using non schema based queries  e.g. `from a in "animals", select: %{a.number_of_feet}` simple sorts work in the same way. However assocs are slightly different. You just need to give the name of the table and the field
e.g:
```
<%= sorted_column @conn, helper: :animal_path, action: :show, assoc: :supplier field: :name %></th>
```
(If a table is joined multiple times in the query it will use the first join for it)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `sortex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sortex, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/sortex](https://hexdocs.pm/sortex).

