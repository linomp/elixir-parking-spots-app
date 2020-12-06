defmodule FmpsWeb.HistoryController do
  use FmpsWeb, :controller

  import Ecto.Query

  alias Fmps.Repo
  alias Fmps.Sales.{Booking}
  alias Fmps.Parking.{ParkingSpot}

  def index(conn, _params) do

    user = Fmps.Authentication.load_current_user(conn)
    query = from b in Booking, where: b.user_id == ^user.id and b.is_paid == true
    bookings = Repo.all(query) |> Repo.preload(:parking_spot)
    render(conn, "index.html", bookings: bookings)
  end

end
