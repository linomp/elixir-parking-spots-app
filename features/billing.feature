Feature: Billing for a booking
    As a user
    such that I am logged in and want to book a parking lot
    I want to be able to pay for it

    Scenario: Successfully paying for a real-time payment booking
        Given I have created a real-time booking
        And I have enough money in my wallet
        And I am in the home page
        When I go to My Ongoing Booking page
        And click on button to pay for my ongoing real-time booking
        Then I get a confirmation message

        
    