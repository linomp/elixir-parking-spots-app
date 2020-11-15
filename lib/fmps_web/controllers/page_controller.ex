defmodule FmpsWeb.PageController do
  use FmpsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
