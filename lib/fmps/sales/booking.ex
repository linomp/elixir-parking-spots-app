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
    |> validate_hours(:start_time, :leaving_time, "Leaving time must be later than start time")
  end

  def validate_hours(changeset, field1, field2, msg) do
    value1 = get_field(changeset, field1)
    value2 = get_field(changeset, field2)
    IO.inspect "**** BOOKING SCHEMA VALIDATION ****"
    IO.inspect value1
    IO.inspect value2

    #case value1 == value2 do
    #  true -> add_error(changeset, field1, msg) |> add_error(field2, msg)
    #  _ -> changeset
    #end

    changeset

  end

end
