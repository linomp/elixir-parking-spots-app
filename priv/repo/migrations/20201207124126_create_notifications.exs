defmodule Fmps.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :address, :string
      add :leaving_time, :time
      add :user_id, references(:users)
    end
  end
end
