defmodule FmpsWeb.MywalletController do
    use FmpsWeb, :controller
    alias Fmps.Repo
    alias Fmps.Accounts.User
    alias Ecto.{Changeset, Multi}

    def index(conn, _params) do
      #render conn, "mywallet.html"
      user = Fmps.Authentication.load_current_user(conn)
      changeset = User.changeset(user, %{})
      render(conn, "mywallet.html", user: user, changeset: changeset)
    end

    def update(conn, %{"input_money" => input_money}) do
      
      user = Fmps.Authentication.load_current_user(conn)
      changeset = Changeset.change(user, %{balance: user.balance + elem(Float.parse(input_money),0)})
      newData = changeset |> Repo.update!()
      IO.inspect newData
      render(conn, "mywallet.html", user: newData, changeset: changeset)
    end


end