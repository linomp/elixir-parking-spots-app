defmodule SettingsContext do
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

  when_ ~r/^I go to settings page$/, fn state ->
    navigate_to "/settings"
    {:ok, state}
  end

  and_ ~r/^I select monthly payment$/, fn state ->
    click({:id, "is_monthly_payment_id"})
    {:ok, state}
  end

  and_ ~r/^I click submit settings$/, fn state ->
    click({:id, "submit_settings"})
    {:ok, state}
  end

  then_ ~r/^I get a confirmation message$/, fn state ->
    assert visible_in_page? ~r/Payment method successfully updated/
    {:ok, state}
  end

end
