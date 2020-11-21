defmodule WhiteBreadContext do
  use WhiteBread.Context
  use Hound.Helpers

  feature_starting_state fn  ->
    Application.ensure_all_started(:hound)
    %{}
  end
  scenario_starting_state fn _state ->
    Hound.start_session
    %{}
  end
  scenario_finalize fn _status, _state -> 
    Hound.end_session
  end

  given_ ~r/^I am in Home page$/, fn state ->
    {:ok, state}
  end

  when_ ~r/^I click to Register button$/, fn state ->
    {:ok, state}
  end

  and_ ~r/^I input my name as "(?<argument_one>[^"]+)", email "(?<argument_two>[^"]+)", licence number "(?<argument_three>[^"]+)", password "(?<argument_four>[^"]+)"$/,
  fn state, %{argument_one: _argument_one,argument_two: _argument_two,argument_three: _argument_three,argument_four: _argument_four} ->
    {:ok, state}
  end

  and_ ~r/^I click Register$/, fn state ->
    {:ok, state}
  end

  then_ ~r/^I am navigated to my account page$/, fn state ->
  {:ok, state}
  end

end
