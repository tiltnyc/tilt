sharedSteps = module.exports = ->
  @World = require("../support/world").World
  
  @Given /^I am an administrator$/, (next) ->
    next()
    
  @Given /^I am on the home page$/, (next) ->
    @visit "/", next

  @Then /^I should see "([^"]*)"$/, (text, next) ->
    @browser.text("body").should.include text
    next()

  @Then /^I should not see "([^"]*)"$/, (text, next) ->
    @browser.text("body").should.not.include text
    next()