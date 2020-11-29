defmodule FmpsWeb.MywalletController do
    use FmpsWeb, :controller
  
    def index(conn, _params) do
      render conn, "mywallet.html"
    end
end