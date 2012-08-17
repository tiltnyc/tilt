Feature: Allocation of funds to users
  In order to allow users to invest
  As an administrator
  I need to allocate seed money to all users per round

  Background:
    Given I am an administrator
    And there exists users:
      | username    | email               |
      | justin      | justin@example.com  |
      | paul        | paul@example.com    |
    And there are 3 rounds

  Scenario: Initial Allocation to Multiple Users
    Given Round 1 is the current round
    When I allocate $100 in Round 1
    Then User "justin" should have $100 for Round 1
    And User "paul" should have $100 for Round 1
    And Round 1 should show $100 allocated

  Scenario: Double Allocation
    Given Round 1 is the current round
    When I allocate $100 in Round 1
    And I allocated $50 in Round 1
    Then User "justin" should have $150 for Round  1
    And Round 1 should show $150 allocated

  Scenario: Negative Allocation
    Given Round 1 is the current round
    When I allocate $100 in Round 1
    And I allocated $-50 in Round 1
    Then User "justin" should have $50 for Round  1
    And User "paul" should have $50 for Round 1
    And Round 1 should show $50 allocated
