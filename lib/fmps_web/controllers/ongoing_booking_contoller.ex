defmodule FmpsWeb.OngoingBookingController do
  use FmpsWeb, :controller
  import Ecto.Query

  alias Fmps.Repo
  alias Fmps.Sales.{Booking}
  alias Fmps.Parking.{ParkingSpot}

  alias Ecto.{Changeset, Multi}

  def index(conn, _params) do

    user = Fmps.Authentication.load_current_user(conn)
    query = from b in Booking, where: b.user_id == ^user.id and b.is_finished == false, order_by: [desc: b.inserted_at], limit: 1
    booking = Repo.one(query)

    if booking !== nil do
      parkingSpot = Repo.get!(ParkingSpot, booking.parking_spot_id) |> Repo.preload(:parking_category)
      priceIfHourly = if booking.is_hourly do
                        Fmps.Prices.getTotalPriceForHourly(booking.start_time, booking.leaving_time, parkingSpot.parking_category)
                      else
                        0
                      end
      render(conn, "index.html", ongoingExists: true, booking: booking, address: parkingSpot.address, priceIfHourly: priceIfHourly)
    else
      render(conn, "index.html", ongoingExists: false, isHourly: false, address: "")
    end
  end

  def create(conn, params) do
    user = Fmps.Authentication.load_current_user(conn)
    query = from b in Booking, where: b.user_id == ^user.id and b.is_finished == false, order_by: [desc: b.inserted_at], limit: 1
    booking = Repo.one(query)

    parkingSpot = Repo.get!(ParkingSpot, booking.parking_spot_id)
    |> Repo.preload(:parking_category)

    if !booking.is_hourly do

      time = if (is_nil(Map.get(params, "currentTime"))) do
        currentTimeInEstonia = Time.add(Time.utc_now(), 2*3600) 
        Fmps.Prices.enhancedTimeDiff(currentTimeInEstonia, booking.start_time)
      else
        Fmps.Prices.enhancedTimeDiff(Map.get(params, "currentTime"), booking.start_time)
      end

      price = Fmps.Prices.getParkingSpotPrices(time, parkingSpot.parking_category).priceIfRealTime

      # if not monthly
      if user.balance < price and !(user.is_monthly_payment) do
        conn
        |> put_flash(:info, "Not enough balance, price is #{price} Euros")
        |> redirect(to: Routes.mywallet_path(conn, :index))
      else

        # if not monthly
        if !(user.is_monthly_payment) do
          Repo.update!( Changeset.change(user, %{balance: Float.ceil(user.balance - price, 2)}))
        end

        case Multi.new
              |> Multi.update(:parking_spot, ParkingSpot.changeset(parkingSpot, %{}) |> Changeset.put_change(:is_available, true))
              |> Multi.update(:booking, Booking.changeset(booking, %{}) |> Changeset.put_change(:is_finished, true) |> Changeset.put_change(:price, price))
              |> Repo.transaction do
                {:ok, _} ->
                  IO.inspect "Success"
                {:error, _} ->
                  IO.inspect "Error"
        end

        newBooking = Repo.get!(Booking, booking.id)

        # set is paid
        if !(user.is_monthly_payment) do
          Repo.update!( Changeset.change(newBooking, %{is_paid: true}))
        end

        conn
        |> put_flash(:info, "Payment successfully done, #{price} Euros")
        |> redirect(to: Routes.page_path(conn, :index))
      end
    else

      conn
      |> put_flash(:info, "Extend")
      |> render("index.html", ongoingExists: true, isHourly: booking.is_hourly, address: parkingSpot.address)
    end

  end


end
