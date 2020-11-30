defmodule Fmps.Sales.Booking do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bookings" do
    field :is_hourly, :boolean, default: true
    field :leaving_time, :time
    field :start_time, :time

    belongs_to :parking_spot, Fmps.Parking.ParkingSpot
    belongs_to :user, Fmps.Accounts.User
    
    timestamps()
  end

  @doc false
  def changeset(booking, attrs) do
    booking
    |> cast(attrs, [:is_hourly, :start_time, :leaving_time])
    |> validate_required([:is_hourly, :start_time])
  end
end
