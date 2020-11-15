defmodule Fmps.Repo do
  use Ecto.Repo,
    otp_app: :fmps,
    adapter: Ecto.Adapters.Postgres
end
