User = require("../../models/user")

module.exports = ->
  @World = require("../support/world").World

  @Given /^this test is pending$/, (next) ->
    next.pending()

  @Given /^I am an administrator$/, (next) ->
    @browser.visit '/', next

  @Given /^I am logged in as an administrator$/, (next) ->
    @browser.visit '/login', (error, browser) ->
      new User({
        username:  'admin',
        email:     'admin@example.com',
        is_admin:  true,
        password:  'password'}).save (error, user) ->
          browser.
            fill('email', user.email).
            fill('password', user.password).
            pressButton 'input[type="submit"]', next

  @Given /^I am on the home ?page$/, (next) ->
    @browser.visit '/', next

  @Then /^I should see "([^"]*)"$/, (text, next) ->
    @browser.text("body").should.include text
    next()

  @Then /^I should not see "([^"]*)"$/, (text, next) ->
    @browser.text("body").should.not.include text
    next()
