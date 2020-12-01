defmodule Fmps.Repo.Migrations.AddWalletToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :balance, :float, default: 0.0
    end  
  end
end
