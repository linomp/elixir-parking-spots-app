defmodule Fmps.Geolocation do
  def getParkingSpotsWithDistances(address, parkingSpots) do

    IO.inspect("address")
    IO.inspect(address)
    [o1, o2] = find_location(address)
    uri = buildDistanceMatrixUri(o1, o2, parkingSpots, get_key())

    try do
      response = HTTPoison.get!(uri)
      {_, responseDecoded} = Poison.decode(response.body)

      [data | _] = responseDecoded |> Map.get("resourceSets")

      [resources2 | _] = data |> Map.get("resources")

      distances =
        resources2
        |> Map.get("results")
        |> Enum.map(fn result -> %{:travelDistance => result |> Map.get("travelDistance"), :travelDuration => result |> Map.get("travelDuration")} end)

      zippedVar = Enum.zip(parkingSpots, distances)
      zippedVar
    rescue
      _ -> Enum.zip(parkingSpots, [])
    end

  end

  def find_location(address) do
    uri =
      "http://dev.virtualearth.net/REST/v1/Locations?q=#{URI.encode(address)}%&key=#{get_key()}"

    response = HTTPoison.get!(uri)

    matches =
      Regex.named_captures(
        ~r/coordinates\D+(?<lat>-?\d+.\d+)\D+(?<long>-?\d+.\d+)/,
        response.body
      )

    try do
      [{v1, _}, {v2, _}] = [matches["lat"] |> Float.parse(), matches["long"] |> Float.parse()]
      [v1, v2]
    rescue
      _ -> [0.0, 0.0]
    end
  end

  def buildDistanceMatrixUri(o1, o2, parkingSpots, key) do
    baseUri =
      "https://dev.virtualearth.net/REST/v1/Routes/DistanceMatrix?key=#{key}&travelMode=walking&distanceUnit=km&origins=#{o1},#{o2}&destinations="

    badstr = Enum.reduce(parkingSpots, baseUri, (fn (spot, acc) -> acc <> "#{spot.latitude},#{spot.longitude};" end))
    badstr |> String.slice(0..-2)
  end

  defp get_key(), do: "Al4PwEJm3cOWDdCeoJEwsd2BlWX55XlE6AedYsEFR5Lca0ccYXj1MsXgRDtksXVm"
end
