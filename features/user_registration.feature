Feature: User registration
  As a user
  such that I don't have access to system features
  I want to register a new account

  Scenario: Registering in the system successfully
    When I go to Registration page
    And I input my name as "Thomas Collins", email "tom.collins@gmail.com", licence number "ET123456", password "parool"
    And I click Register
    Then I get a confirmation message
    
  Scenario: Registering with wrong credentials shows error
    When I go to Registration page
    And I input my name as "Thomas Collins", email "tom.collinsgmail.com", licence number "ET123456", password "parl"
    And I click Register
    Then I get an error message
    