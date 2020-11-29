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
    {:ok, state}
  end
  
  and_ ~r/^click on a parking lot from the list to book it $/, fn state ->
    {:ok, state}
  end

  and_ ~r/^I am navigated to Parking Booking page$/, fn state ->
    {:ok, state}
  end
  
  and_ ~r/^I pick real-time payment$/, fn state ->
    {:ok, state}
  end

  and_ ~r/^I pick hourly payment$/, fn state ->
    {:ok, state}
  end

  and_ ~r/^I enter my start time as "(?<argument_one>[^"]+)"$/,
  fn state, %{argument_one: _argument_one} ->
    {:ok, state}
  end
    
  and_ ~r/^I click submit booking$/, fn state ->
    {:ok, state}
  end

  and_ ~r/^I enter my end time as "(?<argument_one>[^"]+)"$/,
  fn state, %{argument_one: _argument_one} ->
    {:ok, state}
  end

  then_ ~r/^I get a confirmation message$/, fn state ->
    {:ok, state}
  end
  
end
