defmodule FmpsWeb.MywalletControllerTest do
    use FmpsWeb.ConnCase
    use Hound.Helpers

    alias Fmps.{Repo, Accounts.User}
    alias Fmps.Guardian

    setup do
      user =
        Repo.insert!(%User{
        name: "Anna Karenina",
        email: "anna.karenina@gmail.com",
        licence_number: "ES345632",
        password: "parool"
      })
      conn = guardian_login(user)
      {:ok, conn: conn}
    end

    @valid_input("12")
    @invalid_input("-1")
    @invalid_input1("abc")

    def guardian_login(user) do
        build_conn()
        |> bypass_through(Takso.Router, [:browser, :browser_authenticated_session])
        |> get("/")
        |> Map.update!(:state, fn _ -> :set end)
        |> Guardian.Plug.sign_in(user)
        |> send_resp(200, "Flush the session")
        |> recycle
    end

    describe "money input" do
        test "Adds money to balance", %{conn: conn} do
          conn = put(conn, Routes.mywallet_path(conn, :update, 0), input_money: @valid_input)
          assert html_response(conn, 200) =~ ~r/12.0/
        end

        test "returns error in case of negative input ", %{conn: conn} do
            conn = put(conn, Routes.mywallet_path(conn, :update, 0), input_money: @invalid_input)
            conn = get conn, redirected_to(conn)
            assert html_response(conn, 200) =~ ~r/Invalid input/
        end

        test "returns error in case of string input ", %{conn: conn} do
            conn = put(conn, Routes.mywallet_path(conn, :update, 0), input_money: @invalid_input1)
            conn = get conn, redirected_to(conn)
            assert html_response(conn, 200) =~ ~r/Invalid input/
        end
    end
end
