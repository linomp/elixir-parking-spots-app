defmodule FmpsWeb.SettingsController do
  use FmpsWeb, :controller
  alias Fmps.Repo
  alias Fmps.Accounts.User
  alias Ecto.{Changeset, Multi}

  def index(conn, _params) do
    user = Fmps.Authentication.load_current_user(conn)
    changeset = User.changeset(user, %{})
    render(conn, "index.html", user: user, changeset: changeset)
  end

  def update(conn, %{"user" => userParams}) do
    user = Fmps.Authentication.load_current_user(conn)

    try do
      changeset = Changeset.change(user, %{is_monthly_payment: userParams["is_monthly_payment"] })
      changeset |> Repo.update!()
      conn
        |> put_flash(:info, "Payment method successfully updated")
        |> redirect(to: Routes.settings_path(conn, :index))
      rescue
        _ -> conn
             |> put_flash(:info, "Something went wrong")
             |> redirect(to: Routes.settings_path(conn, :index))
    end
  end
end
