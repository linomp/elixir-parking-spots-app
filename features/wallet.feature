Feature: Add money to the wallet
As a user 
Such that I am logged in
I want to add an amount of money to my wallet

Scenario: An amount of money have inputted successfully
When I go to My Wallet page
And I see balance in my wallet 0.0
And I input amount of money 125.0
And I click Add
Then my balance should be updated to 125.0
