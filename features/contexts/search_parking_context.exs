defmodule SearchParkingContext do
  use WhiteBread.Context
  use Hound.Helpers

  alias Fmps.{Repo, Accounts.User, Parking.ParkingCategory}

  feature_starting_state fn  ->
    Application.ensure_all_started(:hound)
    %{}
  end

  scenario_starting_state fn _state ->
    Hound.start_session
    Ecto.Adapters.SQL.Sandbox.checkout(Fmps.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Fmps.Repo, {:shared, self()})

    # Register and login new user for BDD tests
    [%{name: "Anna Karenina", email: "anna.karenina@gmail.com", licence_number: "ES345632", password: "parool"}]
    |> Enum.map(fn user_data -> User.changeset(%User{}, user_data) end)
    |> Enum.each(fn changeset -> Repo.insert!(changeset) end)

    navigate_to "/sessions/new"
    fill_field({:id, "email"}, "anna.karenina@gmail.com")
    fill_field({:id, "password"}, "parool")
    click({:id, "submit_login"})
    :timer.sleep(1000)


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


    %{}
  end

  scenario_finalize fn _status, _state ->
    Ecto.Adapters.SQL.Sandbox.checkin(Fmps.Repo)
    Hound.end_session
  end

  when_ ~r/^I go to Search page$/, fn state ->
    navigate_to "/search"
    {:ok, state}
  end

  and_ ~r/^I input my address as "(?<argument_one>[^"]+)"$/,
  fn state, %{argument_one: argument_one} ->
    fill_field({:id, "address"}, argument_one)
    {:ok, state}
  end

  and_ ~r/^I input my intended leaving hour as "(?<argument_one>[^"]+)"$/,
  fn state, %{argument_one: argument_one} ->
    fill_field({:id, "leavingTime"}, argument_one)

    {:ok, state}
  end

  and_ ~r/^I click Search$/, fn state ->
    click({:id, "search"})
    :timer.sleep(1000)

    {:ok, state}
  end

  then_ ~r/^I get a summary of the available parking lots around$/, fn state ->
    assert visible_in_page? ~r/Zone/
    assert visible_in_page? ~r/Distance/
    assert visible_in_page? ~r/Hourly Rate/
    assert visible_in_page? ~r/Real-Time Rate/

    assert (find_all_elements(:class, "parking-result") |> Enum.count) > 0
    {:ok, state}
  end

  then_ ~r/^I get a summary of the available parking lots around with estimated price info$/, fn state ->
    assert visible_in_page? ~r/Zone/
    assert visible_in_page? ~r/Distance/
    assert visible_in_page? ~r/Hourly Rate/
    assert visible_in_page? ~r/Real-Time Rate/

    assert visible_in_page? ~r/Price \(Hourly\)/
    assert visible_in_page? ~r/Price \(Real-Time\)/

    assert (find_all_elements(:class, "parking-result") |> Enum.count) > 0
    {:ok, state}
  end
end
