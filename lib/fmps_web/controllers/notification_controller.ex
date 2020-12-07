defmodule FmpsWeb.NotificationController do
  use FmpsWeb, :controller

  import Ecto.Query

  alias Fmps.Repo
  alias Fmps.Sales.{Notification}

  def index(conn, _params) do

    user = Fmps.Authentication.load_current_user(conn)
    query = from n in Notification, where: n.user_id == ^user.id
    notifications = Repo.all(query)
    IO.inspect notifications
    render(conn, "index.html", notifications: notifications)
  end

end
