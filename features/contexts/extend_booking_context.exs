defmodule ExtendBookingContext do
  use WhiteBread.Context
  use Hound.Helpers
  import Hound.Matchers

  alias Fmps.{Repo, Accounts.User}
  alias Fmps.Parking.{ParkingCategory}

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
          address: "EXAMPLE_ADDRESS",
          latitude: 58.388034,
          longitude: 26.736930,
          city: "Tartu"
        }]
        |> Enum.map(fn parkingSpotData -> Ecto.build_assoc(categoryA, :spots, parkingSpotData) end)
        |> Enum.each(fn changeset -> Repo.insert!(changeset) end)

    navigate_to "/sessions/new"
    fill_field({:id, "email"}, "anna.karenina@gmail.com")
    fill_field({:id, "password"}, "parool")
    click({:id, "submit_login"})
    :timer.sleep(1000)

    %{}
  end

  scenario_finalize fn _status, _state ->
    Ecto.Adapters.SQL.Sandbox.checkin(Fmps.Repo)
    Hound.end_session
  end

  given_ ~r/^I have enough money in my wallet$/, fn state ->
    navigate_to("/mywallet")
    fill_field({:id, "input_money"}, "125.0")
    click({:id, "add"})
    visible_in_element?({:id, "balance"}, ~r/125.0/iu)
    {:ok, state}
  end

  and_ ~r/^I have created a hourly booking$/, fn state ->
    navigate_to "/search"
    click({:id, "EXAMPLE_ADDRESS"})
    :timer.sleep(1000)

    find_element(:css, "#start_time_hour option[value='12']")
    |> click


    find_element(:css, "#leaving_time_hour option[value='14']")
    |> click

    click({:id, "submit_booking"})

    {:ok, state}
  end



  and_ ~r/^I am in the home page$/, fn state ->
    navigate_to("/")
    {:ok, state}
  end


  when_ ~r/^I go to My Ongoing Booking page$/, fn state ->
    navigate_to("/ongoing-booking")

    assert visible_in_page? ~r/EXAMPLE_ADDRESS/
    assert visible_in_page? ~r/12/
    assert visible_in_page? ~r/14/
    assert visible_in_page? ~r/4.0/
    {:ok, state}
  end

  and_ ~r/^I click the Extend button$/, fn state ->
    click({:id, "extend-hourly"})
    {:ok, state}
  end


  and_ ~r/^enter a new leaving hour for my ongoing booking$/, fn state ->
    find_element(:css, "#leaving_time_hour option[value='16']")
    |> click
    :timer.sleep(1000)

    click({:id, "submit_booking"})
    :timer.sleep(2000)

    {:ok, state}
  end

  then_ ~r/^I get a confirmation message$/, fn state ->

    assert visible_in_page? ~r/Booking extended successfully/
    assert visible_in_page? ~r/EXAMPLE_ADDRESS/
    assert visible_in_page? ~r/12/
    assert visible_in_page? ~r/16/
    assert visible_in_page? ~r/8.0/

    {:ok, state}
  end

  and_ ~r/^I get a confirmation of payment message$/, fn state ->
    assert visible_in_page? ~r/Payment done/
    {:ok, state}
  end

end
