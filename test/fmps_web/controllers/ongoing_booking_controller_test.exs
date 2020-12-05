defmodule FmpsWeb.OngoingBookingControllerTest do
  use FmpsWeb.ConnCase

  alias Fmps.{Repo, Accounts.User, Parking.ParkingCategory}

  alias Fmps.Parking.{ParkingSpot}
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

  @create_attrs %{is_hourly: false, leaving_time: nil, start_time: ~T[14:00:00]}

  @valid_input("10")

  describe "Payment for parking booking" do
    test "payment is rejected if there's not enough balance", %{conn: conn} do

      # book a parking spot
      parkingLot = Repo.get_by(ParkingSpot, name: "Neste")
      conn = get conn, "/booking/#{parkingLot.id}"
      conn = post conn, "/booking", %{"booking"=>@create_attrs}

      conn =
      post conn, "/ongoing-booking", %{
        currentTime: ~T[15:00:00]
      }

      # navigate to wallet page to input money to wallet
      assert "/mywallet" = redir_path = redirected_to(conn, 302)
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ ~r/Not enough balance/

    end


    test "balance of the user is updated correctly after payment", %{conn: conn} do

      # put money into wallet
      conn = put(conn, Routes.mywallet_path(conn, :update, 0), input_money: @valid_input)

      # book a parking spot
      parkingLot = Repo.get_by(ParkingSpot, name: "Neste")
      conn = get conn, "/booking/#{parkingLot.id}"
      conn = post conn, "/booking", %{"booking"=>@create_attrs}

      conn =
      post conn, "/ongoing-booking", %{
        currentTime: ~T[15:00:00]
      }

      # navigate to home page after finishing the booking payment
      assert "/" = redir_path = redirected_to(conn, 302)
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ ~r/Payment successfully done/

      conn = get conn, "/mywallet"
      assert html_response(conn, 200) =~ ~r/<p id=\"balance\">9.04<\/p>/

    end
  end


end
