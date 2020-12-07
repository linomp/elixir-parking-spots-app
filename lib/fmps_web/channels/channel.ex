defmodule FmpsWeb.NotificationChannel do
  use Phoenix.Channel

  def join("notifications:user", _message, socket) do


    #IO.puts("**** SOCKET JOIN ****")
    #IO.inspect socket
    #IO.puts("*********")

    {:ok, socket}
  end


  def handle_in() do
  end

end
