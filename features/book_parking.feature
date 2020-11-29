Feature: Booking a parking lot
    As a user
    such that I am logged in
    I want to be able to book a parking lot

    Scenario: Successfully booking a parking lot with real-time payment
        When I go to search parking lot page
        And click on a parking lot from the list to book it 
        And I am navigated to Parking Booking page
        And I pick real-time payment
        And I enter my start time as "20:00"
        And I click submit booking
        Then I get a confirmation message
    
    Scenario: Successfully booking a parking lot with hourly payment
        When I go to search parking lot page
        And click on a parking lot from the list to book it 
        And I am navigated to Parking Booking page
        And I pick hourly payment
        And I enter my start time as "20:00"
        And I enter my end time as "21:00"
        And I click submit booking
        Then I get a confirmation message
