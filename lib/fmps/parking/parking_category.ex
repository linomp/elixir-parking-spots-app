defmodule Fmps.Parking.Parking_category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "parking_spots" do
    field :name, :string
    field :hourly_rate, :float
    field :real_time_rate, :float
    belongs_to :parking_spot, Fmps.Parking.Parking_spot
  end

  def changeset(parking_category, attrs) do
    parking_category
    |> cast(attrs, [:name, :hourly_rate, :real_time_rate])
  end

end
