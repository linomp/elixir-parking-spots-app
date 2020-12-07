Feature: Parking lot search
    As a user
    such that I am logged in
    I want to search for available parking lots according to my destination

    # Requirement 2.1 BDD, 2.2 BDD
    Scenario: Successful parking lots search
        When I go to Search page
        And I input my address as "Narva maantee 18, 51009 Tartu"
        And I click Search
        Then I get a summary of the available parking lots around

    # Requirement 2.3 BDD, 2.4 BDD
    Scenario: Successful parking lots search with intended leaving hour for getting estimated price info
        When I go to Search page
        And I input my address as "Narva maantee 18, 51009 Tartu"
        And I input my intended leaving hour as "18:00"
        And I click Search
        Then I get a summary of the available parking lots around with estimated price info

