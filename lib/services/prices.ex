defmodule Fmps.Prices do

  def convertRealTimeRate(rate) do
    rate * 12 / 100
  end

  def getParkingSpotsWithPrices(timeInParkingSpot, parkingSpots) do
    parkingSpots |> Enum.map(
      fn spotTuple ->
        parkingCategory = elem(spotTuple, 0).parking_category
        priceIfHour = Float.ceil(timeInParkingSpot) * parkingCategory.hourly_rate
        priceIfRealTime = timeInParkingSpot *  convertRealTimeRate( parkingCategory.real_time_rate )

        if priceIfHour > 0 and priceIfRealTime > 0 do
          {elem(spotTuple, 0), elem(spotTuple, 1), %{:priceIfHour=>priceIfHour, :priceIfRealTime=>Float.ceil(priceIfRealTime, 2)}}
        else
          {elem(spotTuple, 0), elem(spotTuple, 1), %{:priceIfHour=>0, :priceIfRealTime=>0}}
        end
      end
    )
  end

  @spec isValid(any) :: boolean
  def isValid(time) do
    String.match?(time, ~r/^([0-1][0-9]|[2][0-3]):([0-5][0-9])$/) and String.length(time) == 5
  end

end
