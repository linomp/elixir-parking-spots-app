defmodule Fmps.Repo.Migrations.AddBlockNextUpdateToBooking do
  use Ecto.Migration

  def change do
    alter table(:bookings) do
      add :block_next_update, :boolean, default: false
    end
  end
end
