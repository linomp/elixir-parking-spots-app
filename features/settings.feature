Feature: Update payment type
    As a user
    such that I am logged in
    I want to be able to update my payment type

    Scenario: Successfully update payment method to monthly payment
        When I go to settings page
        And I select monthly payment
        And I click submit settings
        Then I get a confirmation message
