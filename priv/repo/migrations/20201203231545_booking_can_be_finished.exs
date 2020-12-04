defmodule Fmps.Repo.Migrations.BookingCanBeFinished do
  use Ecto.Migration

  def change do

    alter table(:bookings) do
      add :is_finished, :boolean, default: false
    end

  end
end
