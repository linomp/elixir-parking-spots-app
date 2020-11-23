defmodule Fmps.Parking.Parking_spot do
  use Ecto.Schema
  import Ecto.Changeset

  schema "parking_spots" do
    field :name, :string
    field :address, :string
    field :latitude, :float
    field :ongitude, :float
    field :city, :string
    has_one :parking_category, Fmps.Parking.Parking_category# I'm new!
    timestamps()
  end

  def changeset(parking_spot, attrs) do
    parking_spot
    |> cast(attrs, [:name, :address, :latitude, :ongitude, :city])
  end

end
