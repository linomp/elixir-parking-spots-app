defmodule FmpsWeb.BookingControllerTest do
  use FmpsWeb.ConnCase

  alias Fmps.Sales

  @create_attrs %{is_hourly: true, leaving_time: ~T[14:00:00], start_time: ~T[14:00:00]}
  @update_attrs %{is_hourly: false, leaving_time: ~T[15:01:01], start_time: ~T[15:01:01]}
  @invalid_attrs %{is_hourly: nil, leaving_time: nil, start_time: nil}

  def fixture(:booking) do
    {:ok, booking} = Sales.create_booking(@create_attrs)
    booking
  end


  defp create_booking(_) do
    booking = fixture(:booking)
    %{booking: booking}
  end
end
