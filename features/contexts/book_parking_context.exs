defmodule BookParkingContext do
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

  when_ ~r/^I go to search parking lot page$/, fn state ->
    navigate_to "/search"
    {:ok, state}
  end
  
  and_ ~r/^click on a parking lot to be navigated to booking page$/, fn state ->
    click({:id, "Peetri 57-59"})
    :timer.sleep(1000)
    {:ok, state}
  end

  and_ ~r/^I pick real-time payment$/, fn state ->
    click({:id, "is_real_time"})
    # uncheck hourly
    click({:id, "is_hourly"})
    {:ok, state}
  end

  and_ ~r/^I pick hourly payment$/, fn state ->
    # hourly is checked by default
    {:ok, state}
  end

  and_ ~r/^^I enter my start time as "(?<argument_one>[^"]+)":"(?<argument_two>[^"]+)"$/,
  fn state, %{argument_one: argument_one, argument_two: argument_two} ->
    find_element(:css, "#start_time_hour option[value='" <> argument_one <> "']")
    |> click
    
    find_element(:css, "#start_time_minute option[value='" <> argument_one <> "']")
    |> click
    {:ok, state}
  end
    
  and_ ~r/^I click submit booking$/, fn state ->
    click({:id, "submit_booking"})
    {:ok, state}
  end

  and_ ~r/^I enter my end time as "(?<argument_one>[^"]+)":"(?<argument_two>[^"]+)"$/,
  fn state, %{argument_one: argument_one, argument_two: argument_two} ->
    find_element(:css, "#leaving_time_hour option[value='" <> argument_one <> "']")
    |> click
    
    find_element(:css, "#leaving_time_minute option[value='" <> argument_two <> "']")
    |> click
    {:ok, state}
  end

  then_ ~r/^I get a confirmation message$/, fn state ->
    assert visible_in_page? ~r/Booking created successfully/
    {:ok, state}
  end
  
end
