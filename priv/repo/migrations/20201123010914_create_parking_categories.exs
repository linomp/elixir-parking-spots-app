defmodule Fmps.Repo.Migrations.CreateParkingCategories do
  use Ecto.Migration

  def change do
    create table(:parking_categories) do
      add :name, :string
      add :hourly_rate, :float
      add :real_time_rate, :float
      add :parking_spot_id, references(:parking_spots)
    end

    create unique_index(:parking_categories, [:parking_spot_id])
  end
end
