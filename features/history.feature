Feature: Check my booking payment history
    As a user
    such that I am logged in
    I want to be able to see my booking payment history

    Scenario: Successfully show the history page
        Given I have a paid, finished booking
        When I click on My History to be navigated to the history page
        Then I see the table of my booking payment history
    