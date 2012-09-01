User = require("../../models/user")

module.exports = ->
  @World = require("../support/world").World

  @After (callback) ->
    @clean callback

  @Given /^there exists users:$/, (table, next) ->
    createUser = (index, callback) ->
      return callback()  if table.hashes().length is index
      item = table.hashes()[index]
      new User(
        username: item.username
        email: item.email
      ).save (err) ->
        return callback(err)  if err
        createUser index + 1, callback
    createUser 0, next

  @When /^I go to the list of users$/, (next) ->
    @visit "/users", next

  @When /^I go to create a new user$/, (next) ->
    @visit "/users/new", next

  @When /^I enter "([^"]*)" as the "([^"]*)"$/, (value, field, next) ->
    @browser.fill field, value, next

  @When /^I click "([^"]*)"$/, (button, callback) ->
    @browser.pressButton button, callback

  @When /^I click the link "([^"]*)" for user "([^"]*)"$/, (link, username, callback) ->
    @browser.onconfirm (text) ->
      true
    @browser.clickLink "tr:contains(" + username + ") a:contains(" + link + ")", callback
