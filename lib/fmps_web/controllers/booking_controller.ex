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

    # TODO: unit test to validate user has enough money
    # TODO: validate user has enough money in wallet
    # TODO: unit test to validate balance is updated
    # TODO: charge user

    case Sales.create_booking(%{"bookingParams"=>booking_params, "user"=>user, "parkingSpot"=>parkingSpot}) do
      {:ok, booking} ->

        Ecto.Changeset.change(parkingSpot, %{is_available: false}) |> Repo.update!()

        conn
        |> put_flash(:info, "#{if booking.is_hourly do "Payment done. " else "" end}Booking created successfully.")
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

     # TODO: unit test to validate user has enough money
     # TODO: validate user has enough money in wallet
     # TODO: unit test to validate balance is updated
     # TODO: charge user

    try do
      leavingTimeParams = Map.get(booking_params, "leaving_time")

      {_status, newLeavingTime} = Time.new(Map.get(leavingTimeParams,"hour") |> String.to_integer, Map.get(leavingTimeParams,"minute") |> String.to_integer, 0, 0)

      # Anything other than the new leaving time being greater than the original leaving time,
      # is interpreted as invalid
      case Time.compare(newLeavingTime, booking.leaving_time) do
        :gt ->  case Sales.update_booking(booking, booking_params) do
                  {:ok, _booking} ->
                    conn
                    |> put_flash(:info, "Payment done. Booking extended successfully.")
                    |> redirect(to: Routes.ongoing_booking_path(conn, :index))

                  {:error, %Ecto.Changeset{} = changeset} ->
                    render(conn, "edit.html", booking: booking, changeset: changeset)
                end
        _ ->    conn
                |> put_flash(:error, "New leaving time must be later than original leaving time")
                |> redirect(to: Routes.booking_path(conn, :edit, booking))
      end
    rescue
      _ -> conn
            |> put_flash(:error, "Something went wrong.")
            |> redirect(to: Routes.booking_path(conn, :edit, booking))
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
