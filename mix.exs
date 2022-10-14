defmodule Sortex.MixProject do
  use Mix.Project

  def project do
    [
      app: :sortex,
      version: "0.2.2",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      aliases: aliases()
    ]
  end

  defp elixirc_paths(:test),
    do: [
      "lib",
      "test/database",
      "test/route_helpers.ex"
    ]

  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: extra_applications(Mix.env())
    ]
  end

  defp extra_applications(:test) do
    [:postgrex, :ecto, :logger]
  end

  defp extra_applications(_) do
    [:logger]
  end

  defp deps do
    [
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:plug, "~> 1.12", only: :test, runtime: false},
      {:phoenix_html, "~> 3.0"},
      {:floki, "~> 0.33.0", only: :test, runtime: false}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*"],
      maintainers: [""],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/WhiteHatuk/sortex"},
      description: "A magical way to add sorting dynamically to ecto queries"
    ]
  end

  defp aliases do
    [test: ["ecto.create", "ecto.migrate", "test"]]
  end
end
