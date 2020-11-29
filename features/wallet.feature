Feature: Add money to the wallet
As a user 
Such that I am logged in
I want to add an amount of money to my wallet

Scenario: An amount of money have inputted successfully
When I go to My Wallet page
And I see current amount of money in my wallet 0.0
And I input amount of money 120.0
And I click Add
Then my current amount of money should be updated to 120.0
