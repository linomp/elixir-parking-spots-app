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

  def create(conn, %{"booking" => booking_params}) do
    case Sales.create_booking(booking_params) do
      {:ok, booking} ->
        conn
        |> put_flash(:info, "Booking created successfully.")
        |> redirect(to: Routes.booking_path(conn, :show, booking))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    booking = Sales.change_booking(%Booking{})
    parkingSpotData = Repo.get!(ParkingSpot, id) |> Repo.preload(:parking_category)
    render(conn, "new.html", changeset: booking, parkingSpot: parkingSpotData)
  end

  def edit(conn, %{"id" => id}) do
    booking = Sales.get_booking!(id)
    changeset = Sales.change_booking(booking)
    render(conn, "edit.html", booking: booking, changeset: changeset)
  end

  def update(conn, %{"id" => id, "booking" => booking_params}) do
    booking = Sales.get_booking!(id)

    case Sales.update_booking(booking, booking_params) do
      {:ok, booking} ->
        conn
        |> put_flash(:info, "Booking updated successfully.")
        |> redirect(to: Routes.booking_path(conn, :show, booking))

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
