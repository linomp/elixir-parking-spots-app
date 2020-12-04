defmodule Fmps.Repo.Migrations.AddMonthlyPaymentSettings do
  use Ecto.Migration

  def change do

    alter table(:users) do
      add :is_monthly_payment, :boolean, default: false
    end

  end

end
