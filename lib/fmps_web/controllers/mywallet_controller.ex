defmodule FmpsWeb.MywalletController do
    use FmpsWeb, :controller
    alias Fmps.Repo
    alias Fmps.Accounts.User
    alias Ecto.{Changeset}

    def index(conn, _params) do
      #render conn, "mywallet.html"
      user = Fmps.Authentication.load_current_user(conn)
      changeset = User.changeset(user, %{})
      render(conn, "mywallet.html", user: user, changeset: changeset)
    end

    def update(conn, %{"input_money" => input_money}) do

      user = Fmps.Authentication.load_current_user(conn)

      try do
        first = elem(Float.parse(input_money),0)
        if is_number(first) && first>0 do
          changeset = Changeset.change(user, %{balance: user.balance + first})
          newData = changeset |> Repo.update!()
          render(conn, "mywallet.html", user: newData, changeset: changeset)
        else
          conn
          |> put_flash(:error, "Invalid input")
          |> redirect(to: Routes.mywallet_path(conn, :index))
        end
      rescue
        _ -> conn
             |> put_flash(:error, "Invalid input")
             |> redirect(to: Routes.mywallet_path(conn, :index))
      end
    end
end
