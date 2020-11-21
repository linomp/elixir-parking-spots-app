defmodule WhiteBreadContext do
  use WhiteBread.Context
  use Hound.Helpers

  feature_starting_state fn  ->
    Application.ensure_all_started(:hound)
    %{}
  end
  scenario_starting_state fn _state ->
    Hound.start_session
    Ecto.Adapters.SQL.Sandbox.checkout(Fmps.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Fmps.Repo, {:shared, self()})
    %{}
  end
  scenario_finalize fn _status, _state -> 
    Ecto.Adapters.SQL.Sandbox.checkin(Fmps.Repo)
    Hound.end_session
  end

  when_ ~r/^I go to Registration page$/, fn state ->
    navigate_to("/users/new")
    {:ok, state}
  end

  and_ ~r/^I input my name as "(?<name>[^"]+)", email "(?<email>[^"]+)", licence number "(?<licence_number>[^"]+)", password "(?<password>[^"]+)"$/,
  fn state, %{name: name,email: email,licence_number: licence_number,password: password} ->

    fill_field({:id, "name"}, name)
    fill_field({:id, "email"}, email)
    fill_field({:id, "licence_number"}, licence_number)
    fill_field({:id, "password"}, password)
    {:ok, state}
  end

  and_ ~r/^I click Register$/, fn state ->
    click({:id, "submit_register"})
    {:ok, state}
  end

  then_ ~r/^I get a confirmation message$/, fn state ->
    assert visible_in_page? ~r/Account registered successfully/
    {:ok, state}
  end

end
