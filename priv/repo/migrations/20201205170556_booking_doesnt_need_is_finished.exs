defmodule Fmps.Repo.Migrations.BookingDoesntNeedIsFinished do
  use Ecto.Migration

  def change do
    alter table(:bookings) do
      remove :is_finished
    end

  end
end
