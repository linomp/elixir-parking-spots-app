defmodule FmpsWeb.PageControllerTest do
  use FmpsWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Find me a parking spot!"
  end
end
