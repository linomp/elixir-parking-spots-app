defmodule FmpsWeb.BookingController do
  use FmpsWeb, :controller
  alias Fmps.Repo
  alias Fmps.Parking.{ParkingSpot}

  def index(conn, params) do
    render(conn, "index.html")
  end

  def show(conn, %{"id" => id}) do

    parkingSpotData = Repo.get!(ParkingSpot, id) |> Repo.preload(:parking_category)
    IO.inspect(parkingSpotData)  
    render(conn, "show.html", parkingSpot: parkingSpotData )
  end


end
