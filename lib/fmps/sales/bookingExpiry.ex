defmodule Fmps.BookingExpiryTask do
  use GenServer

  @ten_seconds 2000

  def init(opts) do

    IO.inspect opts

    #Process.send_after(self(), :tick, @ten_seconds)

    {:ok, opts}
  end

  def handle_info(:tick, state) do
    time =
      DateTime.utc_now()
      |> DateTime.to_time()
      |> Time.to_iso8601()

    IO.puts("The time is now: #{time}")

    #Process.send_after(self(), :tick, @ten_seconds)

    {:noreply, state}
  end
end
