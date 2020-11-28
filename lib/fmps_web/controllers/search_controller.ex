defmodule FmpsWeb.SearchController do
  use FmpsWeb, :controller

  alias Fmps.Repo
  alias Fmps.Parking.{ParkingSpot}

  def index(conn, _params) do
    parkingSpots = Repo.all(ParkingSpot) |> Repo.preload(:parking_category)

    # IO.inspect(parkingSpots)
    render(conn, "index.html", parkingSpots: parkingSpots, processedResults: false)
  end

  def create(conn, params) do
    address = params["address"]
    # IO.inspect(params)


    rawParkingSpots = Repo.all(ParkingSpot) |> Repo.preload(:parking_category)

    parkingSpotsWithDistances = Fmps.Geolocation.getParkingSpotsWithDistances(address, rawParkingSpots) |> filterOutFartherThan(1)

    if (Fmps.Prices.isValid(params["leavingTime"])) do
      {_ , leavingTime} = Time.from_iso8601(params["leavingTime"]<>":00")
      # IO.inspect(leavingTime)
      leavingTime = Time.add(leavingTime, -2*3600)  # TODO: fix some day
      # IO.inspect(leavingTime)

      timeInParkingSpot = Time.diff(leavingTime, Time.utc_now, :second) / 3600
      parkingSpotsWithPrices =  Fmps.Prices.getParkingSpotsWithPrices(timeInParkingSpot, parkingSpotsWithDistances)
      render(conn, "index.html", parkingSpots: parkingSpotsWithPrices, processedResults: true)
    else
      render(conn, "index.html", parkingSpots: parkingSpotsWithDistances |> Enum.map(
        fn spotTuple ->
          {elem(spotTuple, 0), elem(spotTuple, 1), %{:priceIfHour=>"--", :priceIfRealTime=>"--"}}
        end), processedResults: true)
    end
  end

  def filterOutFartherThan(parkingSpots, distanceInKm) do
    parkingSpots |> Enum.filter(fn spotTuple -> elem(spotTuple, 1).travelDistance <= distanceInKm && elem(spotTuple, 1).travelDistance > 0 end) |> Enum.sort_by( (fn spotTuple -> elem(spotTuple, 1).travelDistance end), :asc)
  end

end
