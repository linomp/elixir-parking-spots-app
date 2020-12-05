defmodule Fmps.Repo.Migrations.BookingHasPriceAndIsPaid do
  use Ecto.Migration

  def change do

    alter table(:bookings) do
      add :is_paid, :boolean, default: false
      add :price, :float, default: 0.0
    end

  end
end
