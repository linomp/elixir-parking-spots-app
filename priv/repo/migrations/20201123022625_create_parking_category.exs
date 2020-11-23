defmodule Fmps.Repo.Migrations.CreateParkingCategory do
  use Ecto.Migration

  def change do
    create table(:parking_categories) do
      add :name, :string
      add :hourly_rate, :float
      add :real_time_rate, :float
    end
  end
end
