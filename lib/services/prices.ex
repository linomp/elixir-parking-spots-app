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
        priceIfRealTime = timeInParkingSpot *  convertRealTimeRate( parkingCategory.real_time_rate )

        {elem(spotTuple, 0), elem(spotTuple, 1), %{:priceIfHour=>priceIfHour, :priceIfRealTime=>Float.ceil(priceIfRealTime, 2)}}
      end
    )
  end

  @spec isValid(any) :: boolean
  def isValid(time) do
    if (time) do
      true
    else
      false
    end
  end

end
