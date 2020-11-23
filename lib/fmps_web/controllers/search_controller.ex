defmodule FmpsWeb.SearchController do
  use FmpsWeb, :controller

  alias Fmps.Repo
  alias Fmps.Parking.{ParkingSpot}

  def index(conn, _params) do
    parkingSpots = Repo.all(ParkingSpot)
    IO.inspect(parkingSpots)
    render(conn, "index.html", parkingSpots: parkingSpots)
  end
end
