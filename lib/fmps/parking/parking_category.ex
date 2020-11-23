defmodule Fmps.Parking.ParkingCategory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "parking_categories" do
    field :name, :string
    field :hourly_rate, :float
    field :real_time_rate, :float
  end

  def changeset(parking_category, attrs) do
    parking_category
    |> cast(attrs, [:name, :hourly_rate, :real_time_rate])
  end
end
