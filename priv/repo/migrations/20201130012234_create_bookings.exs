defmodule Fmps.Repo.Migrations.CreateBookings do
  use Ecto.Migration

  def change do
    create table(:bookings) do
      add :is_hourly, :boolean, default: false, null: false
      add :start_time, :time
      add :leaving_time, :time

      timestamps()
    end

  end
end
