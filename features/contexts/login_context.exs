defmodule LoginContext do
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

    [%{name: "Anna Karenina", email: "anna.karenina@gmail.com", licence_number: "ES345632", password: "parool"}]
    |> Enum.map(fn user_data -> User.changeset(%User{}, user_data) end)
    |> Enum.each(fn changeset -> Repo.insert!(changeset) end)

    %{}
  end

  scenario_finalize fn _status, _state -> 
    Ecto.Adapters.SQL.Sandbox.checkin(Fmps.Repo)
    Hound.end_session
  end

  when_ ~r/^I go to Login page$/, fn state ->
    navigate_to("/sessions/new")
    {:ok, state}
  end

  and_ ~r/^I input my email "(?<email>[^"]+)" and password "(?<password>[^"]+)"$/,
  fn state, %{email: email, password: password} ->

    fill_field({:id, "email"}, email)
    fill_field({:id, "password"}, password)
    {:ok, state}
  end

  and_ ~r/^I click Login$/, fn state ->
    click({:id, "submit_login"})
    {:ok, state}
  end

  then_ ~r/^I get welcome message$/, fn state ->
    assert visible_in_page? ~r/Welcome/
    {:ok, state}
  end

  then_ ~r/^I get error message$/, fn state ->
    assert visible_in_page? ~r/Bad User Credentials/
    {:ok, state}
  end

end
