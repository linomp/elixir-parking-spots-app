defmodule FmpsWeb.UserControllerTest do
  use FmpsWeb.ConnCase

  alias Fmps.Accounts

  @valid_input %{
    password: "parool",
    email: "tomcollins@email.com"
  }
  @invalid_user %{
    password: "password",
    email: "someemail@gmail.com"
  }

  describe "user login" do
      test "logs in user with valid input", %{conn: conn} do
          conn = post(conn, Routes.user_path(conn, :create), user: @valid_user)
          assert html_response(conn, 200) =~ ~r/welcome/
      end
      test "returns error in case of invalid input", %{conn: conn} do
          conn = post(conn, Routes.user_path(conn, :create), user: @invalid_user)
          assert html_response(conn, 200) =~ ~r/Bad User Credentials/
      end
  end

end
