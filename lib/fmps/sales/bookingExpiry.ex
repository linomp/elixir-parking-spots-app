defmodule Fmps.BookingExpiryTask do
  use GenServer

  alias Fmps.Repo
  alias Fmps.Sales.{Booking}
  alias Fmps.Accounts.{User}

  # Time offsets from requirements
  # parking release: 2 minutes before booking finishes
  # notification: 10 minutes before booking finishes

  # Time offsets in dev
  # parking release: 30 seconds before booking finishes
  # notification: 1 minute before booking finishes

  # Time offsets in test
  # parking release: 5 seconds before booking finishes
  # notification: 10 seconds booking finishes

  # @parking_expiry_offset (if is_nil(System.get_env("MIX_ENV")) || System.get_env("MIX_ENV") == "dev" do -10 else -5 end)
  # @notification_offset (if is_nil(System.get_env("MIX_ENV")) || System.get_env("MIX_ENV") == "dev" do -30 else -10 end)
  # @ignore_long_bookings (if is_nil(System.get_env("MIX_ENV")) || System.get_env("MIX_ENV") == "dev" do false else true end)

  @parking_expiry_offset (if is_nil(System.get_env("MIX_ENV")) || System.get_env("MIX_ENV") == "dev" || System.get_env("MIX_ENV") == "prod" do -2*60 else -5 end)
  @notification_offset (if is_nil(System.get_env("MIX_ENV")) || System.get_env("MIX_ENV") == "dev" || System.get_env("MIX_ENV") == "prod" do -10*60 else -10 end)
  @ignore_long_bookings (if is_nil(System.get_env("MIX_ENV")) || System.get_env("MIX_ENV") == "dev" || System.get_env("MIX_ENV") == "prod" do false else true end)


  # Requirements 3.4, 3.6

  def init(booking_id) do


    booking = Repo.get_by!(Booking, id: booking_id)

    currentTimeInEstonia = Time.add(Time.utc_now(), 2*3600)

    timeoutForBooking = Time.diff(booking.leaving_time, currentTimeInEstonia, :millisecond)

    parkingReleaseTime = Time.add(booking.leaving_time, @parking_expiry_offset, :second)
    timeoutForParking = Time.diff(parkingReleaseTime, currentTimeInEstonia, :millisecond)
    timeoutForParking = if timeoutForParking > 0 do
                          timeoutForParking
                        else
                          timeoutForBooking
                        end

    notificationTime = Time.add(booking.leaving_time, @notification_offset, :second)
    timeoutForNotification = Time.diff(notificationTime, currentTimeInEstonia, :millisecond)
    timeoutForNotification = if timeoutForNotification > 0 do
                              timeoutForNotification
                            else
                              1000
                            end

    # hardcoded upper limit, just for cleaner output in testing
    if @ignore_long_bookings do
      if (timeoutForBooking > 0) && (timeoutForBooking < 60000) do
        IO.puts("[debug] ENV: #{System.get_env("MIX_ENV")}\nparking_expiry_offset: #{@parking_expiry_offset}\nnotification_offset: #{@notification_offset}")
        IO.puts "\n** ASYNC TASK STARTED FOR BOOKING: #{booking_id} **"
          <> "\nUser will be notified at: #{addAndGetStr(timeoutForNotification)}"
          <> "\nParking will be released at: #{addAndGetStr(timeoutForParking)}"
          <> "\nBooking will finish at: #{addAndGetStr(timeoutForBooking)}\n"

        Process.send_after(self(), :finish_booking, timeoutForBooking)
        Process.send_after(self(), :release_parking, timeoutForParking)
        Process.send_after(self(), :notify_user, timeoutForNotification)
      end
    else
      if (timeoutForBooking > 0) do
        IO.puts("[debug] ENV: #{System.get_env("MIX_ENV")}\nparking_expiry_offset: #{@parking_expiry_offset}\nnotification_offset: #{@notification_offset}")
        IO.puts "\n** ASYNC TASK STARTED FOR BOOKING: #{booking_id} **"
          <> "\nUser will be notified at: #{addAndGetStr(timeoutForNotification)}"
          <> "\nParking will be released at: #{addAndGetStr(timeoutForParking)}"
          <> "\nBooking will finish at: #{addAndGetStr(timeoutForBooking)}\n"

        Process.send_after(self(), :finish_booking, timeoutForBooking)
        Process.send_after(self(), :release_parking, timeoutForParking)
        Process.send_after(self(), :notify_user, timeoutForNotification)
      end
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
        IO.puts "** FINISHING BOOKING #{booking_id} - #{booking.parking_spot.address}**" <> currentTimeStr() <> strTimeDiff(init_time)
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
        IO.puts "** RELEASING PARKING SPOT #{booking.parking_spot.id} (BOOKING #{booking_id} - #{booking.parking_spot.address}) **"  <> currentTimeStr() <> strTimeDiff(init_time)
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
        IO.puts "** CREATING NOTIFICATION (BOOKING #{booking_id}) **" <> currentTimeStr() <> strTimeDiff(init_time)
        user = Repo.get_by!(User, id: booking.user_id)
        notification = Ecto.build_assoc(user, :notifications, %{address: booking.parking_spot.address, leaving_time: booking.leaving_time})
        Repo.insert!(notification)

        FmpsWeb.Endpoint.broadcast!("notifications:user", "new_notification", %{})

      end

      {:noreply, %{"booking_id"=>booking_id, "init_time"=>init_time}}
    rescue
      _ -> {:noreply, %{"booking_id"=>booking_id, "init_time"=>init_time}}
    end

  end

  defp strTimeDiff(init_time) do
    time =
      DateTime.utc_now()
      |> DateTime.to_time()
      |> Time.add(2*3600)
    diff = Time.diff(time, init_time, :second)

    "\nTime elapsed: #{diff} s\n"
  end

  defp addAndGetStr(millis) do
    DateTime.utc_now()
      |> DateTime.to_time()
      |> Time.add(2*3600)
      |> Time.add(millis, :millisecond)
      |> Time.to_iso8601()
  end

  defp currentTimeStr() do
    timestr = DateTime.utc_now()
              |> DateTime.to_time()
              |> Time.add(2*3600)
              |> Time.to_iso8601()

      "\nCurrent Time: #{timestr}"
  end


end
