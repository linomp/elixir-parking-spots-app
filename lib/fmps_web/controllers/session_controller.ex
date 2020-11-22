defmodule FmpsWeb.SessionController do
    use FmpsWeb, :controller

    alias Fmps.Repo
    alias Fmps.Accounts.User

    def new(conn, _params) do
      render conn, "new.html"
    end

    def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
        user = Repo.get_by(User, email: email)
        case Fmps.Authentication.check_credentials(user, password) do
          {:ok, _} ->
            conn
            |> Fmps.Authentication.login(user)
            |> put_flash(:info, "Welcome #{user.name}")
            |> redirect(to: Routes.page_path(conn, :index))
          {:error, _reason} ->
            conn
            |> put_flash(:error,"Bad User Credentials")
            |> render("new.html")
        end
      end

    def delete(conn, _params) do
        conn
        |> Fmps.Authentication.logout()
        |> redirect(to: Routes.page_path(conn, :index))
    end
end