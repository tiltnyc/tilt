Feature: Homepage display
  In order to ensure tilt homepage is functioning
  As a site user
  I want to see information and links to the rest of the application

  Scenario: Visiting the home page
    Given I am on the home page
    Then I should see "tilt"
