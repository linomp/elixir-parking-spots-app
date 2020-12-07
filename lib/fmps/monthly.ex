defmodule Fmps.Periodically do
  use GenServer

  import Ecto.Query

  alias Fmps.Repo
  alias Fmps.Sales.{Booking}
  alias Fmps.Accounts.{User}
  alias Fmps.Parking.{ParkingSpot}

  alias Ecto.{Changeset, Multi}

  def start_link(arg) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work() # Schedule work to be performed at some point
    {:ok, state}
  end

  # Requirement 4.5
  def handle_info(:work, state) do
    bookings = Fmps.Repo.all(Booking) |> Repo.preload(:user)

    for booking <- bookings do
      user = booking.user
      newBalance = user.balance - booking.price
      if booking.user.is_monthly_payment and !(booking.is_paid) and booking.is_finished do
        Repo.update( Changeset.change(user, %{balance: Float.ceil(newBalance, 2)}))
        case Multi.new
              |> Multi.update(:booking, Booking.changeset(booking, %{}) |> Changeset.put_change(:is_paid, true))
              |> Repo.transaction do
                {:ok, _} ->
                  IO.inspect "Monthly Charged!"
                {:error, _} ->
                  IO.inspect "Error"
        end
      end
    end


    schedule_work() # Reschedule once more
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, 30 * 24 * 60 * 60 * 1000) # Repeat monthly
    # Process.send_after(self(), :work, 5000) # often
  end
end
