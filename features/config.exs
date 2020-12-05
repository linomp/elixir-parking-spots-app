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

      suite name:          "Wallet",
            context:       WalletContext,
            feature_paths: ["features/wallet.feature"]

      suite name:          "Book Parking Lots",
            context:       BookParkingContext,
            feature_paths: ["features/book_parking.feature"]

      suite name:          "Update payment method",
            context:       SettingsContext,
            feature_paths: ["features/settings.feature"]

      suite name:          "Billing for booking",
            context:       BillingContext,
            feature_paths: ["features/billing.feature"]

      suite name:          "Extending a booking",
            context:       ExtendBookingContext,
            feature_paths: ["features/extend_booking.feature"]

end
