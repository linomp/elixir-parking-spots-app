Feature: Parking lot search
    As a user
    such that I am logged in
    I want to search for available parking lots according to my destination

    Scenario: Successful parking lots search
        When I go to Search page
        And I input my address as "Narva maantee 18, 51009 Tartu"
        And I click Search
        Then I get a summary of the available parking lots around

