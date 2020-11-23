defmodule SearchParkingContext do
  use WhiteBread.Context
  use Hound.Helpers

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

  when_ ~r/^I go to Search page$/, fn state ->
    navigate_to "/search"
    {:ok, state}
  end

  and_ ~r/^I input my address as "(?<argument_one>[^"]+)"$/,
  fn state, %{argument_one: argument_one} ->
    fill_field({:id, "address"}, argument_one)
    {:ok, state}
  end

  and_ ~r/^I click Search$/, fn state ->
    click({:id, "search"})
    {:ok, state}
  end

  then_ ~r/^I get a summary of the available parking lots around$/, fn state ->
    assert visible_in_page? ~r/Zone/
    assert visible_in_page? ~r/Distance/
    {:ok, state}
  end

end
