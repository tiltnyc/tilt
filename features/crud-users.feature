Feature: Admins CRUD of Users
  In order to manage the collection of users
  As an administrator of tilt
  I want to be able to create, read, update and delete users in the system

  Background:
    Given there exists users:
      | username    | email               |
      | justin      | justin@example.com  |
      | paul        | paul@example.com    |

  Scenario: See the list of users
    Given I am an administrator
    When I go to the list of users
    Then I should see "justin"

  Scenario: Create a new user
    Given I am an administrator
    When I go to create a new user
    And I enter "peter" as the "Username"
    And I enter "peter@example.com" as the "Email"
    And I click "Submit"
    Then I should see "peter"
    And I should see "peter@example.com"

  Scenario: Delete a user
    Given I am an administrator
    When I go to the list of users
    And I click the link "Del" for user "paul"
    Then I should see "justin"
    And I should not see "paul"
