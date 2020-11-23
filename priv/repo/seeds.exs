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


alias Fmps.{Repo, Parking.Parking_spot, Parking.Parking_category}


[%{id: 1 ,name: "Parking1", address: "Abc streety 45", latitude: 12.12, ongitude: 1.00, city: "Tartu"},
 %{id: 2 ,name: "Parking2", address: "Abc streety 4", latitude: 12.12, ongitude: 1.00, city: "Tartu"}]
|> Enum.map(fn parking_spot_data -> Parking_spot.changeset(%Parking_spot{}, parking_spot_data) end)
|> Enum.each(fn changeset -> Repo.insert!(changeset) end)



[%{name: "A", hourly_rate: 2, real_time_rate: 16, parking_spot_id: 1},
 %{name: "B", hourly_rate: 1, real_time_rate: 8, parking_spot_id: 2 }]
|> Enum.map(fn parking_category -> Parking_category.changeset(%Parking_spot{}, parking_category) end)
|> Enum.each(fn changeset -> Repo.insert!(changeset) end)



# field :name, :string
# field :address, :string
# field :latitude, :float
# field :ongitude, :float
# field :city, :string
# has_one :parking_category,
