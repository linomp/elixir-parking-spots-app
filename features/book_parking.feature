# Requirement 3.1 BDD, 3.2 BDD
Feature: Booking a parking lot
    As a user
    such that I am logged in
    I want to be able to book a parking lot

    Scenario: Successfully booking a parking lot with real-time payment
        When I go to search parking lot page
        And click on a parking lot to be navigated to booking page
        And I pick real-time payment
        And I enter my start time as "12":"12"
        And I click submit booking
        Then I get a confirmation message
    
    Scenario: Successfully booking a parking lot with hourly payment
        Given I have enough money in my wallet
        When I go to search parking lot page
        And click on a parking lot to be navigated to booking page
        And I pick hourly payment
        And I enter my start time as "12":"12"
        And I enter my end time as "14":"14"
        And I click submit booking
        Then I get a confirmation message
        And I get a confirmation of payment message