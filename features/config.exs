defmodule WhiteBreadConfig do
  use WhiteBread.SuiteConfiguration

  suite name:          "Register",
        context:       WhiteBreadContext,
        feature_paths: ["features/user_registration.feature"]

  suite name:          "Login",
        context:       LoginContext,
        feature_paths: ["features/user_login.feature"]

  suite name:          "Search Parking Lots",
        context:       SearchParkingContext,
        feature_paths: ["features/search_parking.feature"]

  suite name:          "Book Parking Lots",
        context:       BookParkingContext,
        feature_paths: ["features/book_parking.feature"]

end
