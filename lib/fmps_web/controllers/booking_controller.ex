defmodule NotEnoughFundsError do
  defexception message: "Not enough funds!"
end

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
    parkingSpot = Repo.get!(ParkingSpot, conn.cookies["parking_spot_id"]) |> Repo.preload(:parking_category)

    try do

      # This is literally the worst thing I have written in my life. Please refactor this and fire me.
      price = if booking_params["is_hourly"] == true || booking_params["is_hourly"] == "true" do
                temp = Booking.changeset(%Booking{}, booking_params)
                Fmps.Prices.getTotalPriceForHourly(temp.changes.start_time, temp.changes.leaving_time, parkingSpot.parking_category)
              else
                0
              end

      # if not monthly
      if !(user.is_monthly_payment) and Booking.changeset(%Booking{}, booking_params).valid? && price > user.balance do
        raise NotEnoughFundsError
      end

      if !(user.is_monthly_payment) do
        case Sales.create_booking(%{"bookingParams"=>booking_params, "user"=>user, "parkingSpot"=>parkingSpot, "is_paid"=>true, "price"=>price}) do
          {:ok, booking} ->

            Ecto.Changeset.change(parkingSpot, %{is_available: false}) |> Repo.update!()

            # if not monthly
            if booking.is_hourly do
              Ecto.Changeset.change(user, %{balance: user.balance - price}) |> Repo.update!()
            end

            conn
            |> put_flash(:info, "#{if booking.is_hourly do "Payment done. " else "" end}Booking created successfully.")
            |> redirect(to: Routes.ongoing_booking_path(conn, :index))

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "new.html", changeset: changeset, parkingSpot: %{:address=>parkingSpot.address})
        end
      else
        case Sales.create_booking(%{"bookingParams"=>booking_params, "user"=>user, "parkingSpot"=>parkingSpot, "price"=>price}) do
          {:ok, booking} ->

            Ecto.Changeset.change(parkingSpot, %{is_available: false}) |> Repo.update!()

            conn
            |> put_flash(:info, "#{if booking.is_hourly do "Payment done. " else "" end}Booking created successfully.")
            |> redirect(to: Routes.ongoing_booking_path(conn, :index))

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "new.html", changeset: changeset, parkingSpot: %{:address=>parkingSpot.address})
        end
      end

    rescue
      e in NotEnoughFundsError -> conn
           |> put_flash(:error, e.message)
           |> redirect(to: Routes.search_path(conn, :index))
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
    user = Fmps.Authentication.load_current_user(conn)
    booking = Sales.get_booking!(id)
    parkingSpot = Repo.get!(ParkingSpot, booking.parking_spot_id) |> Repo.preload(:parking_category)

    try do

      leavingTimeParams = Map.get(booking_params, "leaving_time")

      {_status, newLeavingTime} = Time.new(Map.get(leavingTimeParams,"hour") |> String.to_integer, Map.get(leavingTimeParams,"minute") |> String.to_integer, 0, 0)

      # Anything other than the new leaving time being greater than the original leaving time,
      # is interpreted as invalid
      case Time.compare(newLeavingTime, booking.leaving_time) do
        :gt ->  oldPrice = Fmps.Prices.getTotalPriceForHourly(booking.start_time, booking.leaving_time, parkingSpot.parking_category)
                newPrice = Fmps.Prices.getTotalPriceForHourly(booking.start_time, newLeavingTime, parkingSpot.parking_category)
                difference = newPrice - oldPrice

                # if not monthly
                if !(user.is_monthly_payment) and Booking.changeset(%Booking{}, booking_params).valid? && difference > user.balance do
                  raise NotEnoughFundsError
                end

                if !(user.is_monthly_payment) do
                  case Sales.update_booking(booking, booking_params) do
                    {:ok, booking} ->

                      Sales.update_booking(booking, %{"price"=>newPrice})

                      Ecto.Changeset.change(user, %{balance: user.balance - difference}) |> Repo.update!()

                      conn
                      |> put_flash(:info, "Payment done. Booking extended successfully.")
                      |> redirect(to: Routes.ongoing_booking_path(conn, :index))

                    {:error, %Ecto.Changeset{} = changeset} ->
                      render(conn, "edit.html", booking: booking, changeset: changeset)
                  end
                else
                  case Sales.update_booking(booking, booking_params) do
                    {:ok, booking} ->

                      Sales.update_booking(booking, %{"price"=>newPrice})

                      conn
                      |> put_flash(:info, "Payment done. Booking extended successfully.")
                      |> redirect(to: Routes.ongoing_booking_path(conn, :index))

                    {:error, %Ecto.Changeset{} = changeset} ->
                      render(conn, "edit.html", booking: booking, changeset: changeset)
                  end
            
                end
        _ ->    conn
                |> put_flash(:error, "New leaving time must be later than original leaving time")
                |> redirect(to: Routes.booking_path(conn, :edit, booking))
      end
    rescue
      e in NotEnoughFundsError -> conn
           |> put_flash(:error, e.message)
           |> redirect(to: Routes.search_path(conn, :index))

      e ->  IO.inspect e
            conn
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
