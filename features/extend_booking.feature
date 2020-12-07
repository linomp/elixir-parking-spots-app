# Requirement 3.5 BDD, 4.1 BDD, 4.2 BDD
Feature: Extending a booking
    As a user
    such that I am logged in and have booked a parking lot
    I want to be able to extend its duration

    Scenario: Successfully extending a hourly payment booking
        Given I have enough money in my wallet
        And I have created a hourly booking
        And I am in the home page
        When I go to My Ongoing Booking page
        And I click the Extend button
        And enter a new leaving hour for my ongoing booking
        Then I get a confirmation message
        And I get a confirmation of payment message