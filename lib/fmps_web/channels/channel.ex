defmodule FmpsWeb.NotificationChannel do
  use Phoenix.Channel

  def join("notifications:user", _message, socket) do

    {:ok, socket}
  end


  def handle_in() do
  end

end
