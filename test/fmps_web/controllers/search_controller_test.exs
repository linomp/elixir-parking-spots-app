defmodule FmpsWeb.SearchControllerTest do
  use FmpsWeb.ConnCase
  use Hound.Helpers

  alias Fmps.{Repo, Accounts.User, Parking.ParkingCategory}
  alias Fmps.Guardian

  setup do
    categoryA =
      Repo.insert!(
        ParkingCategory.changeset(%ParkingCategory{}, %{
          name: "A",
          hourly_rate: 2,
          real_time_rate: 16 # cents / 5 min.
        })
      )

      categoryB =
        Repo.insert!(
          ParkingCategory.changeset(%ParkingCategory{}, %{
            name: "B",
            hourly_rate: 1,
            real_time_rate: 8
          })
        )

    [
      %{
        name: "Ujula Konsum",
        address: "Ujula Konsum",
        latitude: 58.386461,
        longitude: 26.724499,
        city: "Tartu"
      },
      %{
        name: "Tartu Train Station",
        address: "Tartu Train Station",
        latitude: 58.373519,
        longitude: 26.707704,
        city: "Tartu"
      },
      %{
        name: "Tartu Hospital",
        address: "Tartu Hospital",
        latitude: 58.369377,
        longitude: 26.701694,
        city: "Tartu"
      }
    ]
    |> Enum.map(fn parkingSpotData -> Ecto.build_assoc(categoryA, :spots, parkingSpotData) end)
    |> Enum.each(fn changeset -> Repo.insert!(changeset) end)

    [
      %{
        name: "Neste",
        address: "Neste",
        latitude: 58.384469,
        longitude: 26.726815,
        city: "Tartu"
      }]

    |> Enum.map(fn parkingSpotData -> Ecto.build_assoc(categoryB, :spots, parkingSpotData) end)
    |> Enum.each(fn changeset -> Repo.insert!(changeset) end)

    user =
      Repo.insert!(%User{
        name: "Anna Karenina",
        email: "anna.karenina@gmail.com",
        licence_number: "ES345632",
        password: "parool"
      })

    conn = guardian_login(user)
    {:ok, conn: conn}
  end

  def guardian_login(user) do
    build_conn()
    |> bypass_through(Takso.Router, [:browser, :browser_authenticated_session])
    |> get("/")
    |> Map.update!(:state, fn _ -> :set end)
    |> Guardian.Plug.sign_in(user)
    |> send_resp(200, "Flush the session")
    |> recycle
  end

  describe "Parking spot search" do
    test "Returns places within an arbitrary radius", %{conn: conn} do
      conn =
        post conn, "/search", %{
          address: "Narva maantee 18, 51009 Tartu"
        }
      # conn = get(conn, redirected_to(conn))

      # Should display names of close locations
      assert html_response(conn, 200) =~ ~r/Ujula Konsum/
      assert html_response(conn, 200) =~ ~r/Neste/
      # Should not display names of far locations
      refute html_response(conn, 200) =~ ~r/Tartu Train Station/
      refute html_response(conn, 200) =~ ~r/Tartu Hospital/
    end
  end

  describe "Parking spot search with intended leaving hour" do
    test "Returns places within an arbitrary radius + estimated prices", %{conn: conn} do

      currentTime = Time.utc_now()

      conn =
        post conn, "/search", %{
          address: "Narva maantee 18, 51009 Tartu",
          leavingTime: Time.add(currentTime, 2*3600, :second),
          currentTime: currentTime
        }
      # conn = get(conn, redirected_to(conn))

      # Should display names of close locations
      assert html_response(conn, 200) =~ ~r/Ujula Konsum/
      assert html_response(conn, 200) =~ ~r/Neste/

      # Ujula Konsum estimations
      html_response(conn, 200)
      |> assert_select("td.estimated-for-hour", match: "4.00") # hour  (zone A hourly * hours of stay)
      |> assert_select("td.estimated-for-real-time", match: convertRealTimeRate(16)*2)

       # Neste estimations
       html_response(conn, 200)
       |> assert_select("td.estimated-for-hour", match: "4.00")
       |> assert_select("td.estimated-for-real-time", match: convertRealTimeRate(8)*2)

      # Should not display names of far locations
      refute html_response(conn, 200) =~ ~r/Tartu Train Station/
      refute html_response(conn, 200) =~ ~r/Tartu Hospital/
    end
  end

  def convertRealTimeRate(rate) do
    #cents/5min  to cents/min  to eur/hour
    rate * (1/5) *(1/100) * (60/1)
  end


end
