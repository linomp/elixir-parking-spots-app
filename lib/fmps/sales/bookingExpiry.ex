defmodule Fmps.BookingExpiryTask do
  use GenServer

  #import Ecto.Query

  alias Fmps.Repo
  alias Fmps.Sales.{Booking}
  #alias Fmps.Accounts.{User}
  #alias Fmps.Parking.{ParkingSpot}

  #alias Ecto.{Changeset, Multi}

  @parking_expiry_offset -120

  def printTime() do
    time =
      DateTime.utc_now()
      |> DateTime.to_time()
      |> Time.to_iso8601()

    IO.puts("Time: #{time}\n")
  end

  def init(booking_id) do

    booking = Repo.get_by!(Booking, id: booking_id)

    timeWhenParkingShouldBeUpdated = Time.add(booking.leaving_time, @parking_expiry_offset, :second)

    timeoutForParking = Time.diff(timeWhenParkingShouldBeUpdated, Time.utc_now(), :millisecond)
    timeoutForParking = if timeoutForParking > 0 do
                          timeoutForParking
                        else
                          10
                        end

    timeoutForBooking = Time.diff(booking.leaving_time, Time.utc_now(), :millisecond)

    if timeoutForBooking > 0 do
      IO.puts "** ASYNC TASK FIRED FOR BOOKING: #{booking_id} **"
      printTime()

      IO.puts "Booking will finish in: #{Float.round(timeoutForBooking/(1000), 3)} s"
      IO.puts "Parking will be released in: #{Float.round(timeoutForParking/(1000), 3)} s\n"

      Process.send_after(self(), :finish_booking, timeoutForBooking)
      Process.send_after(self(), :release_parking, timeoutForParking)
      #Process.send_after(self(), :notify_user, timeoutForNotification)
    end


    {:ok, booking_id}
  end

  def handle_info(:finish_booking, booking_id) do

    try do
      IO.puts "** FINISHING BOOKING #{booking_id} **"
      printTime()

      booking = Repo.get_by!(Booking, id: booking_id) |> Repo.preload(:parking_spot)
      #IO.inspect booking

      Ecto.Changeset.change(booking, %{is_finished: true}) |> Repo.update!()

      {:noreply, booking_id}
    rescue
      _ -> {:noreply, booking_id}
    end

  end

  def handle_info(:release_parking, booking_id) do

    try do
      booking = Repo.get_by!(Booking, id: booking_id) |> Repo.preload(:parking_spot)
      #IO.inspect booking
      IO.puts "** RELEASING PARKING SPOT #{booking.parking_spot.id} (BOOKING #{booking_id}) **"
      printTime()

      Ecto.Changeset.change(booking.parking_spot, %{is_available: true}) |> Repo.update!()

      {:noreply, booking_id}
    rescue
      _ -> {:noreply, booking_id}
    end

  end
end
