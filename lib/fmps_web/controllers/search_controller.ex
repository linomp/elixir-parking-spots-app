defmodule FmpsWeb.SearchController do
  use FmpsWeb, :controller

  alias Fmps.Repo
  alias Fmps.Parking.{ParkingSpot}

  def index(conn, _params) do
    parkingSpots = Repo.all(ParkingSpot) |> Repo.preload(:parking_category)

    IO.inspect(parkingSpots)
    render(conn, "index.html", parkingSpots: parkingSpots, processedResults: false)
  end

  def create(conn, params) do
    address = params["address"]
    IO.inspect(params)
    rawParkingSpots = Repo.all(ParkingSpot) |> Repo.preload(:parking_category)

    parkingSpotsWithDistance = Fmps.Geolocation.getParkingSpotsWithDistances(address, rawParkingSpots) |> filterOutFartherThan(1)

    IO.inspect(parkingSpotsWithDistance)
    render(conn, "index.html", parkingSpots: parkingSpotsWithDistance, processedResults: true)
  end

  def filterOutFartherThan(parkingSpots, distanceInKm) do
    parkingSpots |> Enum.filter(fn spotTuple -> elem(spotTuple, 1).travelDistance <= distanceInKm end) |> Enum.sort_by( (fn spotTuple -> elem(spotTuple, 1).travelDistance end), :asc)
  end

end
