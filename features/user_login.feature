Feature: User login
  As a user
  such that I don't have access to system features
  I want to register a new account

  Scenario: Login into the system successfully
    When I go to Login page
    And I input my email "anna.karenina@gmail.com" and password "parool"
    And I click Login
    Then I get welcome message
  
  Scenario: Login rejected from the system
    When I go to Login page
    And I input my email "nosuchuser@gmail.com" and password "parool"
    And I click Login
    Then I get error message

  Scenario: Logout works successfully
    Given I am logged in
    When I click Logout
    Then I am being logged out of the system
    
  