defmodule Fmps.Sales.Notification do
  use Ecto.Schema

  schema "notifications" do
    field :address, :string
    field :leaving_time, :time
    field :is_unread, :boolean, default: true
    belongs_to :user, Fmps.Accounts.User
  end
end
