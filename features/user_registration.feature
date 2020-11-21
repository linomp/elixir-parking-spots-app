Feature: User registration
  As a user
  such that I don't have access to system features
  I want to register a new account

  Scenario: Registering in the system successfully
    Given I am in Home page
    When I click to Register button
    And I input my name as "Tom", email "tom.collins@gmail.com", licence number "ET123456", password "parool"
    And I click Register
    Then I get a confirmation message