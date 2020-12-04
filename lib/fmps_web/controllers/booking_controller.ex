defmodule FmpsWeb.BookingController do
  use FmpsWeb, :controller
  alias Fmps.Repo
  alias Fmps.Parking.{ParkingSpot}

  alias Fmps.Sales
  alias Fmps.Sales.Booking

  def index(conn, _params) do
    bookings = Sales.list_bookings()
    render(conn, "index.html", bookings: bookings)
  end

  def new(conn, _params) do
    bookings = Sales.list_bookings()
    render(conn, "index.html", bookings: bookings)
  end

  def create(conn, %{"booking"=>booking_params}) do
    user = Fmps.Authentication.load_current_user(conn)

    # Read parking id from cookie (previously set in show)
    parkingSpot = Repo.get!(ParkingSpot, conn.cookies["parking_spot_id"])

    case Sales.create_booking(%{"bookingParams"=>booking_params, "user"=>user, "parkingSpot"=>parkingSpot}) do
      {:ok, _booking} ->

        Ecto.Changeset.change(parkingSpot, %{is_available: false}) |> Repo.update!()

        conn
        |> put_flash(:info, "Booking created successfully.")
        |> redirect(to: Routes.ongoing_booking_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, parkingSpot: %{:address=>parkingSpot.address})
    end
  end

  def show(conn, %{"id" => id}) do
    booking = Sales.change_booking(%Booking{})
    parkingSpotData = Repo.get!(ParkingSpot, id) |> Repo.preload(:parking_category)
    # Set the parking id in a cookie, to read when booking creation needs to be re-tried
    conn = put_resp_cookie(conn, "parking_spot_id", "#{parkingSpotData.id}")
    render(conn, "new.html", changeset: booking, parkingSpot: parkingSpotData)
  end

  def edit(conn, %{"id" => id}) do
    booking = Sales.get_booking!(id)
    changeset = Sales.change_booking(booking)
    render(conn, "edit.html", booking: booking, changeset: changeset)
  end

  def update(conn, %{"id" => id, "booking" => booking_params}) do
    booking = Sales.get_booking!(id)
    # TODO: logic to update

    case Sales.update_booking(booking, booking_params) do
      {:ok, booking} ->
        conn
        |> put_flash(:info, "Booking extended successfully")
        |> redirect(to: Routes.ongoing_booking_path(conn, :index))
        #|> redirect(to: Routes.booking_path(conn, :show, booking))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", booking: booking, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    booking = Sales.get_booking!(id)
    {:ok, _booking} = Sales.delete_booking(booking)

    conn
    |> put_flash(:info, "Booking deleted successfully.")
    |> redirect(to: Routes.booking_path(conn, :index))
  end
end
