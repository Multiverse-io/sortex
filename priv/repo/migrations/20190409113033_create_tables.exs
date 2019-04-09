defmodule Sorter.Repo.Migrations.CreateTables do
  use Ecto.Migration

  def change do

    create table :suppliers do
      add :name, :string, null: false
    end

    create table :accomodation do
      add :name, :string, null: false
    end

    create table :storage do
      add :temperature, :integer, null: false
    end

    create table :feed do
      add :type, :string, null: false
      add :supplier_id, references("suppliers"), null: false
      add :storage_id, references("storage"), null: false
    end

    create table :animals do
      add :number_of_legs, :integer, null: false
      add :feed_id, references("feed"), null: false
      add :accomodation_id, references("accomodation"), null: false
    end
  end
end
