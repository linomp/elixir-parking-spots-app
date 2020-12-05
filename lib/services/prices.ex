defmodule Fmps.Prices do

  def convertRealTimeRate(rate) do
    rate * 12 / 100
  end

  def getTotalPriceForHourly(start_time, leaving_time, parkingCategory)do
    timeInParkingSpot = enhancedTimeDiff(leaving_time, start_time)
    Float.ceil(timeInParkingSpot) * parkingCategory.hourly_rate
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

  def getParkingSpotPrices(time, parkingCategory) do
      priceIfHour = Float.ceil(time) * parkingCategory.hourly_rate
      priceIfRealTime = time *  convertRealTimeRate( parkingCategory.real_time_rate )

      if priceIfHour > 0 and priceIfRealTime > 0 do
        %{:priceIfHour=>priceIfHour, :priceIfRealTime=>Float.ceil(priceIfRealTime, 2)}
      else
        %{:priceIfHour=>0, :priceIfRealTime=>0}
      end
  end

  @spec isValid(any) :: boolean
  def isValid(time) do
    String.match?(time, ~r/^([0-1][0-9]|[2][0-3]):([0-5][0-9])$/) and String.length(time) == 5
  end

  def enhancedTimeDiff(time_1, time_2) do
    simpleDiff =  Time.diff(time_1, time_2, :second) / 3600
    if simpleDiff <= 0 do
      simpleDiff + 24
    else
      simpleDiff
    end
  end

end
