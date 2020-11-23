defmodule Fmps.Repo.Migrations.CreateParkingSpot do
  use Ecto.Migration

  def change do
    create table(:parking_spots) do
      add :name, :string
      add :address, :string
      add :latitude, :float
      add :ongitude, :float
      add :city, :string
      timestamps()
    end

  end
end
