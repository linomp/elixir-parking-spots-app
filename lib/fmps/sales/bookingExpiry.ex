defmodule Fmps.BookingExpiryTask do
  use GenServer

  #import Ecto.Query

  alias Fmps.Repo
  alias Fmps.Sales.{Booking}
  alias Fmps.Accounts.{User}
  #alias Fmps.Parking.{ParkingSpot}

  #alias Ecto.{Changeset, Multi}

  @parking_expiry_offset (if !is_nil(System.get_env("MIX_ENV")) && System.get_env("MIX_ENV") == "test" do -5 else -2*60 end)
  @notification_offset (if !is_nil(System.get_env("MIX_ENV")) && System.get_env("MIX_ENV") == "test" do -10 else -10*60 end)
  #@ignore_long_bookings (if !is_nil(System.get_env("MIX_ENV")) && System.get_env("MIX_ENV") == "test" do true else false end)

  defp printTime() do
    time =
      DateTime.utc_now()
      |> DateTime.to_time()
      |> Time.add(2*3600)
      |> Time.to_iso8601()

    IO.puts("Time in Estonia: #{time}\n")
  end

  defp printTimeDiff(init_time) do
    time =
      DateTime.utc_now()
      |> DateTime.to_time()
      |> Time.add(2*3600)
    diff = Time.diff(time, init_time, :second)

    IO.puts("Time elapsed: #{diff} s\n")
  end

  def init(booking_id) do

    booking = Repo.get_by!(Booking, id: booking_id)

    currentTimeInEstonia = Time.add(Time.utc_now(), 2*3600)

    parkingReleaseTime = Time.add(booking.leaving_time, @parking_expiry_offset, :second)
    timeoutForParking = Time.diff(parkingReleaseTime, currentTimeInEstonia, :millisecond)
    timeoutForParking = if timeoutForParking > 0 do
                          timeoutForParking
                        else
                          10
                        end

    notificationTime = Time.add(booking.leaving_time, @notification_offset, :second)
    timeoutForNotification = Time.diff(notificationTime, currentTimeInEstonia, :millisecond)

    timeoutForBooking = Time.diff(booking.leaving_time, currentTimeInEstonia, :millisecond)

    if (timeoutForBooking > 0) && (timeoutForBooking < 60000) do
      IO.puts "** ASYNC TASK STARTED FOR BOOKING: #{booking_id} **"
      IO.puts "User will be notified in: #{Float.round(timeoutForNotification/(1000), 2)} s"
      IO.puts "Parking will be released in: #{Float.round(timeoutForParking/(1000), 2)} s"
      IO.puts "Booking will finish in: #{Float.round(timeoutForBooking/(1000), 2)} s\n"

      Process.send_after(self(), :finish_booking, timeoutForBooking)
      Process.send_after(self(), :release_parking, timeoutForParking)
      Process.send_after(self(), :notify_user, timeoutForNotification)
    end


    init_time =
      DateTime.utc_now() |> DateTime.to_time() |> Time.add(2*3600)

    {:ok, %{"booking_id"=>booking_id, "init_time"=>init_time}}
  end

  def handle_info(:finish_booking, %{"booking_id"=>booking_id, "init_time"=>init_time}) do

    try do
      booking = Repo.get_by!(Booking, id: booking_id) |> Repo.preload(:parking_spot)

      # Booking could be blocked from being marked as finished due to an extension
      if booking.block_next_update do
        Ecto.Changeset.change(booking, %{block_next_update: false}) |> Repo.update!()
      else
        IO.puts "** FINISHING BOOKING #{booking_id} **"
        printTimeDiff(init_time)
        Ecto.Changeset.change(booking, %{is_finished: true, block_next_update: false}) |> Repo.update!()
      end

      {:noreply, %{"booking_id"=>booking_id, "init_time"=>init_time}}
    rescue
      _ -> {:noreply, %{"booking_id"=>booking_id, "init_time"=>init_time}}
    end

  end

  def handle_info(:release_parking, %{"booking_id"=>booking_id, "init_time"=>init_time}) do

    try do
      booking = Repo.get_by!(Booking, id: booking_id) |> Repo.preload(:parking_spot)

      if !booking.block_next_update do
        IO.puts "** RELEASING PARKING SPOT #{booking.parking_spot.id} (BOOKING #{booking_id}) **"
        printTimeDiff(init_time)
        Ecto.Changeset.change(booking.parking_spot, %{is_available: true}) |> Repo.update!()
      end

      {:noreply, %{"booking_id"=>booking_id, "init_time"=>init_time}}
    rescue
      _ -> {:noreply, %{"booking_id"=>booking_id, "init_time"=>init_time}}
    end

  end

  def handle_info(:notify_user, %{"booking_id"=>booking_id, "init_time"=>init_time}) do

    try do
      booking = Repo.get_by!(Booking, id: booking_id) |> Repo.preload(:parking_spot)

      if !booking.block_next_update do
        IO.puts "** CREATING NOTIFICATION (BOOKING #{booking_id}) **"
        printTimeDiff(init_time)
        user = Repo.get_by!(User, id: booking.user_id)
        notification = Ecto.build_assoc(user, :notifications, %{address: booking.parking_spot.address, leaving_time: booking.leaving_time})
        #IO.inspect notification
        Repo.insert!(notification)
      end

      {:noreply, %{"booking_id"=>booking_id, "init_time"=>init_time}}
    rescue
      _ -> {:noreply, %{"booking_id"=>booking_id, "init_time"=>init_time}}
    end

  end
end
