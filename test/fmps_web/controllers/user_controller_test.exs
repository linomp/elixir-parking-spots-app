defmodule FmpsWeb.UserControllerTest do
  use FmpsWeb.ConnCase

  alias Fmps.Accounts

  @valid_user %{
    password: "parool",
    name: "Tom Collings",
    licence_number: "ES123452",
    email: "tomcollins@email.com"
  }
  @existing_user %{
    password: "parool",
    name: "Tom Collings",
    licence_number: "ES123452",
    email: "existinguser@email.com"
  }
  @invalid_user %{
    password: nil,
    name: nil,
    licence_number: nil,
    email: nil
  }

  describe "user registration" do
      test "registers users with valid input", %{conn: conn} do
          conn = post(conn, Routes.user_path(conn, :create), user: @valid_user)
          assert html_response(conn, 200) =~ ~r/Account registered successfully/
      end
      test "returns error in case of invalid input", %{conn: conn} do
          conn = post(conn, Routes.user_path(conn, :create), user: @invalid_user)
          assert html_response(conn, 400) =~ ~r/Inputs are invalid/
      end
      test "returns error if a user with same email already exists", %{conn: conn} do
          conn = post(conn, Routes.user_path(conn, :create), user: @existing_user)
          assert html_response(conn, 400) =~ ~r/Account with same email already exists/
      end
  end

end
