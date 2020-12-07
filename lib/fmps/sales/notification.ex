defmodule Fmps.Sales.Notification do
  use Ecto.Schema

  schema "notifications" do
    field :address, :string
    field :leaving_time, :time
    belongs_to :user, Fmps.Accounts.User
  end
end
