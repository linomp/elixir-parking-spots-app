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

  def update(conn, payment_params) do
    user = Fmps.Authentication.load_current_user(conn)
    IO.inspect("test")
    IO.inspect(payment_params)
    conn
      |> put_flash(:info, "Payment method successfully updated")
      |> redirect(to: Routes.settings_path(conn, :index))

    # try do
    #     elemPaymentMethod = elem(Float.parse(set_payment_method),0)
    #     if is_number(elemPaymentMethod) && elemPaymentMethod>0 do
    #       changeset = Changeset.change(user, %{is_monthly_payment: user.is_monthly_payment })
    #       newData = changeset |> Repo.update!()
    #       render(conn, "settings.html", user: newData, changeset: changeset)
    #     else
    #       conn
    #       |> put_flash(:info, "Invalid input")
    #       |> redirect(to: Routes.settings_path(conn, :index))
    #     end
    #   rescue
    #     _ -> conn
    #          |> put_flash(:info, "Invalid input")
    #          |> redirect(to: Routes.settings_path(conn, :index))
    # end
  end
end
