defmodule FmpsWeb.OngoingBookingController do
  use FmpsWeb, :controller
  import Ecto.Query

  alias Fmps.Repo
  alias Fmps.Sales.{Booking}

  def index(conn, _params) do
    
    user = Fmps.Authentication.load_current_user(conn)
    query = from b in Booking, where: b.user_id == ^user.id and b.is_finished == false, order_by: [desc: b.inserted_at], limit: 1
    booking = Repo.one(query)
    if booking !== nil do
      render(conn, "index.html", ongoingExists: true, isHourly: booking.is_hourly)
    else
      render(conn, "index.html", ongoingExists: false, isHourly: false)
    end
  end

  def create(conn, _params) do
    user = Fmps.Authentication.load_current_user(conn)
    query = from b in Booking, where: b.user_id == ^user.id and b.is_finished == false, order_by: [desc: b.inserted_at], limit: 1
    booking = Repo.one(query)
    
    if !booking.is_hourly do
      conn
      |> put_flash(:info, "Payment successfully done")
      |> render("index.html", ongoingExists: true, isHourly: booking.is_hourly)
    else 
      conn
      |> put_flash(:info, "Extend")
      |> render("index.html", ongoingExists: true, isHourly: booking.is_hourly)
    end

  end

end
