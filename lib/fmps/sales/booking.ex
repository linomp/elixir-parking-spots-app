defmodule Fmps.Sales.Booking do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bookings" do
    field :is_hourly, :boolean, default: true
    field :leaving_time, :time
    field :start_time, :time

    belongs_to :parking_spot, Fmps.Parking.ParkingSpot
    belongs_to :user, Fmps.Accounts.User

    
    field :is_finished, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(booking, attrs) do
    booking
    |> cast(attrs, [:is_hourly, :start_time, :leaving_time, :is_finished])
    |> validate_required([:is_hourly, :start_time])
    |> validate_hours(:start_time, :leaving_time, "Leaving time must be later than start time")
  end

  def validate_hours(changeset, startField, leavingField, msg) do
    start = get_field(changeset, startField)
    leaving = get_field(changeset, leavingField)

    try do
      case Time.compare(leaving, start) do
        :gt -> changeset # only leaving > start is valid
        _ -> add_error(changeset, leavingField, msg)
      end
    rescue
      _ -> changeset
    end

  end

end
