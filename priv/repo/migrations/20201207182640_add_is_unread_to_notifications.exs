defmodule Fmps.Repo.Migrations.AddIsUnreadToNotifications do
  use Ecto.Migration

  def change do
    alter table(:notifications) do
      add :is_unread, :boolean, default: true
    end
  end
end
