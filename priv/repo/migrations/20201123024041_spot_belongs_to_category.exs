defmodule Fmps.Repo.Migrations.SpotBelongsToCategory do
  use Ecto.Migration

  def change do
    alter table(:parking_spots) do
      add :parking_category_id, references(:parking_categories)
    end
  end
end
