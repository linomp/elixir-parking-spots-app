defmodule WhiteBreadConfig do
  use WhiteBread.SuiteConfiguration

  suite name:          "Register",
        context:       WhiteBreadContext,
        feature_paths: ["features/user_registration.feature"]

  suite name:          "Login",
        context:       LoginContext,
        feature_paths: ["features/user_login.feature"]
end