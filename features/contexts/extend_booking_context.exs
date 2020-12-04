defmodule ExtendBookingContext do
  use WhiteBread.Context
  use Hound.Helpers
  import Hound.Matchers

  alias Fmps.{Repo, Accounts.User}

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

    %{}

  end

  scenario_finalize fn _status, _state ->
    Ecto.Adapters.SQL.Sandbox.checkin(Fmps.Repo)
    Hound.end_session
  end

  given_ ~r/^I have created a hourly booking$/, fn state ->
    navigate_to "/search"
    click({:id, "Peetri 57-59"})
    :timer.sleep(1000)

    find_element(:css, "#start_time_hour option[value='12']")
    |> click


    find_element(:css, "#leaving_time_hour option[value='14']")
    |> click

    click({:id, "submit_booking"})

    {:ok, state}
  end

  and_ ~r/^I have enough money in my wallet$/, fn state ->
    navigate_to("/mywallet")
    fill_field({:id, "input_money"}, "125.0")
    click({:id, "add"})
    visible_in_element?({:id, "balance"}, ~r/125.0/iu)
    {:ok, state}
  end

  and_ ~r/^I am in the home page$/, fn state ->
    navigate_to("/")
    {:ok, state}
  end


  when_ ~r/^I go to My Ongoing Booking page$/, fn state ->
    navigate_to("/ongoing-booking")
    {:ok, state}
  end

  and_ ~r/^I click the Extend button$/, fn state ->
    click({:id, "extend-hourly"})
    {:ok, state}
  end


  and_ ~r/^enter a new leaving hour for my ongoing booking$/, fn state ->
    find_element(:css, "#leaving_time_hour option[value='16']")
    |> click

    click({:id, "extend_booking"})

    {:ok, state}
  end

  then_ ~r/^I get a confirmation message$/, fn state ->

    # TODO: find leaving time field with updated value

    assert visible_in_page? ~r/Booking extended successfully/

    {:ok, state}
  end
end
