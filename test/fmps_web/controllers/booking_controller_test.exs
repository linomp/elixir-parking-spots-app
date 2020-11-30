defmodule FmpsWeb.BookingControllerTest do
  use FmpsWeb.ConnCase

  alias Fmps.Sales

  alias Fmps.{Repo, Accounts.User, Parking.ParkingCategory}
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
        name: "a1",
        address: "Peetri 57-59",
        latitude: 58.388034,
        longitude: 26.736930,
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

  @create_attrs %{is_hourly: true, leaving_time: ~T[14:00:00], start_time: ~T[14:00:00]}
  @update_attrs %{is_hourly: false, leaving_time: ~T[15:01:01], start_time: ~T[15:01:01]}
  @invalid_attrs %{is_hourly: nil, leaving_time: nil, start_time: nil}
  @invalid_hours_attrs %{is_hourly: true, leaving_time: ~T[13:01:01], start_time: ~T[15:01:01]}

  def fixture(:booking) do
    {:ok, booking} = Sales.create_booking(@create_attrs)
    booking
  end

  defp create_booking() do
    booking = fixture(:booking)
    %{booking: booking}
  end

  describe "Booking" do
    test "Creates a valid booking", %{conn: conn} do

      conn = post conn, "/booking", @create_attrs
      conn = get(conn, redirected_to(conn))

      # Should display names of close locations
      assert html_response(conn, 200) =~ ~r/Booking created successfully/
    end

    test "Shows error message on invalid booking", %{conn: conn} do

      conn = post conn, "/booking", @invalid_hours_attrs
      conn = get(conn, redirected_to(conn))

      # Should display names of close locations
      assert html_response(conn, 200) =~ ~r/Leaving time must be later than start time/
    end
  end



end
