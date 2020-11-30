defmodule Fmps.Repo.Migrations.UpdateParkingSpotsAvailability do
  use Ecto.Migration

  def change do

    alter table(:parking_spots) do
      add :is_available, :boolean, default: true
    end

  end
end
