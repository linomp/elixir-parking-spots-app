defmodule FmpsWeb.BookingControllerTest do
  use FmpsWeb.ConnCase
  use Hound.Helpers
  import Ecto.Query

  alias Fmps.Sales
  alias Fmps.Sales.{Booking}

  alias Fmps.{Repo, Accounts.User, Parking.ParkingCategory}

  alias Fmps.Parking.{ParkingSpot}
  alias Fmps.Guardian

  setup do

    # Create parking spots
    categoryA =
      Repo.insert!(
        ParkingCategory.changeset(%ParkingCategory{}, %{
          name: "A",
          hourly_rate: 2,
          real_time_rate: 16
        })
      )

    [
      %{
        name: "a1",
        address: "Vaike-Turu 1",
        latitude: 58.378163,
        longitude: 26.733274,
        city: "Tartu"
      },
      %{
        name: "a3",
        address: "Puiestee 110",
        latitude: 58.386518,
        longitude: 26.737152,
        city: "Tartu"
      },
      %{
        name: "a2",
        address: "Peetri 57-59",
        latitude: 58.388034,
        longitude: 26.736930,
        city: "Tartu"
      },
      %{
        name: "Neste",
        address: "Neste",
        latitude: 58.384469,
        longitude: 26.726815,
        city: "Tartu"
      },
      %{
        name: "Ujula Konsum",
        address: "Ujula Konsum",
        latitude: 58.386461,
        longitude: 26.724499,
        city: "Tartu"
      }]
      |> Enum.map(fn parkingSpotData -> Ecto.build_assoc(categoryA, :spots, parkingSpotData) end)
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

  @create_attrs %{is_hourly: true, leaving_time: ~T[15:00:00], start_time: ~T[14:00:00]}
  @invalid_hours_attrs %{is_hourly: true, leaving_time: ~T[13:01:01], start_time: ~T[15:01:01]}

  #@update_attrs %{is_hourly: false, leaving_time: ~T[15:01:01], start_time: ~T[15:01:01]}
  #@invalid_update_attrs %{is_hourly: nil, leaving_time: nil, start_time: nil}


  def fixture(:booking) do
    {:ok, booking} = Sales.create_booking(@create_attrs)
    booking
  end

  #defp create_booking() do
  #  booking = fixture(:booking)
  #  %{booking: booking}
  #end

  describe "Booking" do
    test "Creates a valid booking", %{conn: conn} do

      [firstLot | _] = Repo.all(ParkingSpot)

      conn = get conn, "/booking/#{firstLot.id}"
      conn = post conn, "/booking", %{"booking"=>@create_attrs}
      conn = get(conn, redirected_to(conn))

      assert html_response(conn, 200) =~ ~r/Booking created successfully/
    end

    test "Shows error message on invalid booking", %{conn: conn} do

      [firstLot | _] = Repo.all(ParkingSpot)

      conn = get conn, "/booking/#{firstLot.id}"
      conn = post conn, "/booking", %{"booking"=>@invalid_hours_attrs}
      #conn = get(conn, redirected_to(conn))

      assert html_response(conn, 200) =~ ~r/Leaving time must be later than start time/
    end


    test "Blocks parking spot availability after booking", %{conn: conn} do

      # Book specifically Neste spot
      knownParkingLot = Repo.get_by(ParkingSpot, name: "Neste")

      conn = get conn, "/booking/#{knownParkingLot.id}"
      conn = post conn, "/booking", %{"booking"=>@create_attrs}
      conn = get(conn, redirected_to(conn))

      # Booking should succeed
      assert html_response(conn, 200) =~ ~r/Booking created successfully/

      # Search for place that normally would include Neste
      conn =
        post conn, "/search", %{
          address: "Narva maantee 18, 51009 Tartu",
          leavingTime: ""
        }
      # Should display names of close locations, except the already booked
      assert html_response(conn, 200) =~ ~r/Ujula Konsum/
      refute html_response(conn, 200) =~ ~r/Neste/

      conn = get conn, "/search"
      refute html_response(conn, 200) =~ ~r/Neste/
    end

    test "Allows to extend a booking", %{conn: conn} do
      query = from p in ParkingSpot, where: p.is_available
      [firstLot | _] = Repo.all(query)

      # create a booking to then update it
      conn = get conn, "/booking/#{firstLot.id}"
      conn = post conn, "/booking", %{"booking"=> %{is_hourly: true, leaving_time: ~T[14:00:00], start_time: ~T[12:00:00]}}
      conn = get(conn, redirected_to(conn))

       # assert booking was created with initial values
       html_response(conn, 200)
       |> assert_select("li#start_time", match: ~r/12/)
       html_response(conn, 200)
       |> assert_select("li#leaving_time", match: ~r/14/)
       html_response(conn, 200)
       |> assert_select("li#price_if_hourly", match: ~r/4/)

      query = from b in Booking, where: b.parking_spot_id == ^firstLot.id, order_by: [desc: b.inserted_at], limit: 1
      booking = Repo.one(query)

      conn = put conn, "/booking/#{booking.id}", %{"booking"=> %{"leaving_time"=> %{"hour"=>"16", "minute"=>"0"}}}
      conn = get(conn, redirected_to(conn))


      # assert new booking has updated leaving hour and total price
      html_response(conn, 200)
      |> assert_select("li#start_time", match: ~r/12/)
      html_response(conn, 200)
      |> assert_select("li#leaving_time", match: ~r/16/)
      html_response(conn, 200)
      |> assert_select("li#price_if_hourly", match: ~r/8/)
    end


    test "Shows error on invalid leaving hour extension", %{conn: conn} do
      query = from p in ParkingSpot, where: p.is_available
      [firstLot | _] = Repo.all(query)

      # create a booking to then update it
      conn = get conn, "/booking/#{firstLot.id}"
      conn = post conn, "/booking", %{"booking"=> %{is_hourly: true, leaving_time: ~T[14:00:00], start_time: ~T[12:00:00]}}
      conn = get(conn, redirected_to(conn))

       # assert booking was created with initial values
       html_response(conn, 200)
       |> assert_select("li#start_time", match: ~r/12/)
       html_response(conn, 200)
       |> assert_select("li#leaving_time", match: ~r/14/)
       html_response(conn, 200)
       |> assert_select("li#price_if_hourly", match: ~r/4/)

      query = from b in Booking, where: b.parking_spot_id == ^firstLot.id, order_by: [desc: b.inserted_at], limit: 1
      booking = Repo.one(query)

      conn = put conn, "/booking/#{booking.id}", %{"booking"=> %{"leaving_time"=> %{"hour"=>"13", "minute"=>"0"}}}
      conn = get(conn, redirected_to(conn))

      assert html_response(conn, 200) =~ ~r/New leaving time must be later than original leaving time/
    end


  end


end
