# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Fmps.Repo.insert!(%Fmps.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Fmps.{Repo, Parking.ParkingCategory}

# Seed Categories in db
categoryA =
  Repo.insert!(
    ParkingCategory.changeset(%ParkingCategory{}, %{
      name: "A",
      hourly_rate: 2,
      real_time_rate: 16
    })
  )

categoryB =
  Repo.insert!(
    ParkingCategory.changeset(%ParkingCategory{}, %{
      name: "B",
      hourly_rate: 1,
      real_time_rate: 8
    })
  )

# Create some category A parking spots
[
  %{
    name: "Parking1",
    address: "Abc streety 45",
    latitude: 12.12,
    longitude: 1.00,
    city: "Tartu"
  },
  %{
    name: "Parking2",
    address: "Abc streety 4",
    latitude: 12.12,
    longitude: 1.00,
    city: "Tartu"
  }
]
|> Enum.map(fn parkingSpotData -> Ecto.build_assoc(categoryA, :spots, parkingSpotData) end)
|> Enum.each(fn changeset -> Repo.insert!(changeset) end)

# Create some category B parking spots
[
  %{
    name: "Parking3",
    address: "BBB streety 45",
    latitude: 30.12,
    longitude: 5.00,
    city: "Tartu"
  }
]
|> Enum.map(fn parkingSpotData -> Ecto.build_assoc(categoryB, :spots, parkingSpotData) end)
|> Enum.each(fn changeset -> Repo.insert!(changeset) end)
