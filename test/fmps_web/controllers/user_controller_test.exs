defmodule FmpsWeb.UserControllerTest do
  use FmpsWeb.ConnCase

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

  # Requirement 1.1 TDD
  describe "user registration" do
    test "registers users with valid input", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @valid_user)
      assert html_response(conn, 302) =~ ~r/redirected/
    end

    test "returns error in case of invalid input", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_user)
      assert html_response(conn, 200) =~ ~r/can&#39;t be blank/
    end

    test "returns error if a user with same email already exists", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @existing_user)
      conn = post(conn, Routes.user_path(conn, :create), user: @existing_user)
      assert html_response(conn, 200) =~ ~r/has already been taken/
    end
  end
end
