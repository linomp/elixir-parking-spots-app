defmodule Fmps.Prices do

  def convertRealTimeRate(rate) do
    #cents/5min  to cents/min  to eur/hour
    # IO.inspect rate * 12 / 100
    rate * 12 / 100
  end


  def getParkingSpotsWithPrices(timeInParkingSpot, parkingSpots) do
    parkingSpots |> Enum.map(
      fn spotTuple ->
        parkingCategory = elem(spotTuple, 0).parking_category
        priceIfHour = Float.ceil(timeInParkingSpot) * parkingCategory.hourly_rate
        if priceIfHour > 0 do
          priceIfHour = 0
        end
        priceIfRealTime = timeInParkingSpot *  convertRealTimeRate( parkingCategory.real_time_rate )
        if priceIfRealTime > 0 do
          priceIfRealTime = 0
        end
        {elem(spotTuple, 0), elem(spotTuple, 1), %{:priceIfHour=>priceIfHour, :priceIfRealTime=>Float.ceil(priceIfRealTime, 2)}}
      end
    )
  end

  @spec isValid(any) :: boolean
  def isValid(time) do
    String.match?(time, ~r/^([0-1][0-9]|[2][0-3]):([0-5][0-9])$/)
  end

end
