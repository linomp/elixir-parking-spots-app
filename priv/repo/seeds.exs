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
    name: "a1",
    address: "Peetri 57-59",
    latitude: 58.388034,
    longitude: 26.736930,
    city: "Tartu"
  },
  %{
    name: "a2",
    address: "Puiestee 77-81",
    latitude: 58.385927,
    longitude: 26.737827,
    city: "Tartu"
  },
  %{
    name: "a3",
    address: "Puiestee 110",
    latitude: 58.386518,
    longitude: 26.737152,
    city: "Tartu"
  },
  %{
    name: "a4",
    address: "Puiestee 112",
    latitude: 58.385505,
    longitude: 26.739925,
    city: "Tartu"
  },
  %{
    name: "a5",
    address: "Jaama 58-60",
    latitude: 58.383485,
    longitude: 26.742208,
    city: "Tartu"
  },
  %{
    name: "a6",
    address: "Anne 7",
    latitude: 58.381827,
    longitude: 26.742818,
    city: "Tartu"
  },
  %{
    name: "a7",
    address: "Parna 2",
    latitude: 58.380616,
    longitude: 26.737882,
    city: "Tartu"
  },
  %{
    name: "a8",
    address: "Pikk 64",
    latitude: 58.380214,
    longitude: 26.740544,
    city: "Tartu"
  },
  %{
    name: "a9",
    address: "Paju 12-10",
    latitude: 58.380175,
    longitude: 26.743410,
    city: "Tartu"
  },
  %{
    name: "a10",
    address: "Kalda tee 16",
    latitude: 58.373480,
    longitude: 26.758679,
    city: "Tartu"
  }
]
|> Enum.map(fn parkingSpotData -> Ecto.build_assoc(categoryA, :spots, parkingSpotData) end)
|> Enum.each(fn changeset -> Repo.insert!(changeset) end)

# Create some category B parking spots
[
  %{
    name: "b1",
    address: "Vaike-Turu 1",
    latitude: 58.378163,
    longitude: 26.733274,
    city: "Tartu"
  },
  %{
    name: "b2",
    address: "Vaike-Turu 4",
    latitude: 58.377430,
    longitude: 26.734850,
    city: "Tartu"
  },
  %{
    name: "b3",
    address: "Turu 16",
    latitude: 58.378163,
    longitude: 26.736298,
    city: "Tartu"
  },
  %{
    name: "b4",
    address: "Aleksandri 7",
    latitude: 58.375219,
    longitude: 26.730677,
    city: "Tartu"
  },
  %{
    name: "b5",
    address: "Aida 6",
    latitude: 58.373109,
    longitude: 26.732983,
    city: "Tartu"
  },
  %{
    name: "b6",
    address: "Kalevi 10",
    latitude: 58.375174,
    longitude: 26.728252,
    city: "Tartu"
  },
  %{
    name: "b7",
    address: "Aleksandri 4",
    latitude: 58.376293,
    longitude: 26.729028,
    city: "Tartu"
  },
  %{
    name: "b8",
    address: "Ulikooli 14-10",
    latitude: 58.379498,
    longitude: 26.722039,
    city: "Tartu"
  },
  %{
    name: "b9",
    address: "Ulikooli 1",
    latitude: 58.378664,
    longitude: 26.722929,
    city: "Tartu"
  },
  %{
    name: "b10",
    address: "Riia 1",
    latitude: 58.378256,
    longitude: 26.728527,
    city: "Tartu"
  },
]
|> Enum.map(fn parkingSpotData -> Ecto.build_assoc(categoryB, :spots, parkingSpotData) end)
|> Enum.each(fn changeset -> Repo.insert!(changeset) end)
