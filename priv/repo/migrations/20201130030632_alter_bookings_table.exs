defmodule Fmps.Repo.Migrations.AlterBookingsTable do
  use Ecto.Migration

  def change do
    alter table(:bookings) do
      add :parking_spot_id, references(:parking_spots)
      add :user_id, references(:users)
    end
  end
end
