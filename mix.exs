defmodule Sorter.MixProject do
  use Mix.Project

  def project do
    [
      app: :sorter,
      version: "0.1.0",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp elixirc_paths(:test),
    do: [
      "lib",
      "test/database"
    ]

  defp elixirc_paths(_), do: ["lib"]


  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: extra_applications(Mix.env)
    ]
  end

  defp extra_applications(:test) do
    [:postgrex, :ecto, :logger]
  end

  defp extra_applications(_) do
    [:logger]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # p
      #
      #p
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
