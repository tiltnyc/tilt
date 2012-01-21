Feature: Admins CRUD of Users
  In order to manage the collection of users 
  As an administrator of tilt
  I want to be able to create, read, update and delete users in the system

  Scenario: See the list of users
    Given I am an administrator
    And there exists users:
      | username    | email               |
      | justin      | justin@example.com  | 
      | paul        | pppp                |
    When I go to the list of users
    Then I should see "justin"
    And the database should be cleaned

  Scenario: Create a new user
    Given I am an administrator
    When I go to create a new user
    And I enter "peter" as the "Username"
    And I enter "peter@example.com" as the "Email"
    And I click "Submit"
    Then I should see "peter"
    And I should see "peter@example.com"
    And the database should be cleaned
  
  