defmodule Fmps.Parking.ParkingSpot do
  use Ecto.Schema
  import Ecto.Changeset

  schema "parking_spots" do
    field :name, :string
    field :address, :string
    field :latitude, :float
    field :longitude, :float
    field :city, :string
    timestamps()

    # we can then access info about the spot's category via  spot.category
    belongs_to :category, Fmps.Parking.ParkingCategory
  end

  def changeset(parking_spot, attrs) do
    parking_spot
    |> cast(attrs, [:name, :address, :latitude, :longitude, :city])
  end
end
