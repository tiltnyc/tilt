Feature: Admins CRUD of Users
  In order to manage the collection of users 
  As an administrator of tilt
  I want to be able to create, read, update and delete users in the system

  Scenario: See the list of users
    Given I am an administrator
    And there exists users:
    | username    | email               |
    | justin      | justin@example.com  |
    When I visit the list of users
    Then I should see "justin"