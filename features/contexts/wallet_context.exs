defmodule WalletContext do
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

  when_ ~r/^I go to My Wallet page$/, fn state ->
    navigate_to("/mywallet")
    {:ok, state}
  end

  and_ ~r/^I see balance in my wallet 0.0$/, fn state ->
    visible_in_element?({:id, "balance"}, ~r/0.0/iu)
    {:ok, state}
  end

  and_ ~r/^I input amount of money 125.0$/, fn state ->
    fill_field({:id, "input_money"}, "125.0")
    {:ok, state}
  end

  and_ ~r/^I click Add$/, fn state ->
    click({:id, "add"})
    {:ok, state}
  end

  then_ ~r/^my balance should be updated to 125.0$/, fn state ->
    visible_in_element?({:id, "balance"}, ~r/125.0/iu)
    {:ok, state}
  end


end
