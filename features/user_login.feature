Feature: User login
  As a user
  such that I don't have access to system features
  I want to register a new account

  Scenario: Login into the system successfully
    When I go to Login page
    And I input my email "tom.collins@gmail.com" and password "parool"
    And I click Login
    Then I get welcome message
  