defmodule FmpsWeb.SearchController do
  use FmpsWeb, :controller

  alias Fmps.Repo
  alias Fmps.Parking.{ParkingSpot}

  def index(conn, _params) do
    parkingSpots = Repo.all(ParkingSpot)
    |> Repo.preload(:parking_category)
    |> Enum.filter(fn spot -> spot.is_available end)

    render(conn, "index.html", parkingSpots: parkingSpots, processedResults: false)
  end

  def enhancedTimeDiff(time_1, time_2) do
    Time.diff(time_1, time_2, :second) / 3600
  end

  def create(conn, params) do
    address = params["address"]

    rawParkingSpots = Repo.all(ParkingSpot) |> Repo.preload(:parking_category)

    parkingSpotsWithDistances =
      Fmps.Geolocation.getParkingSpotsWithDistances(address, rawParkingSpots)
      |> filterOutFartherThan(1)
      |> filterOutNonAvailable()

    if (Fmps.Prices.isValid(params["leavingTime"])) do
      {_ , leavingTime} = Time.from_iso8601(params["leavingTime"]<>":00")

      IO.inspect leavingTime

      timeInParkingSpot = if (is_nil(Map.get(params, "currentTime"))) do
                            currentTimeInEstonia = Time.add(Time.utc_now(), 2*3600)  # TODO: fix some day
                            enhancedTimeDiff(leavingTime, currentTimeInEstonia)
                          else
                            enhancedTimeDiff(leavingTime, Map.get(params, "currentTime"))
                          end

      IO.inspect timeInParkingSpot

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

  def filterOutNonAvailable(parkingSpots) do
    parkingSpots |> Enum.filter(fn spotTuple -> elem(spotTuple, 0).is_available end)
  end

end
