User = require "../../models/user"
Round = require "../../models/round"

module.exports = ->
  @World = require("../support/world").World
  @After (callback) ->
    @clean callback

  @Given /^there are (\d+) rounds$/, (numRounds, next) ->
    next.pending()

  @Given /^Round (\d+) is the current round$/, (round, next) ->
    next.pending()

  @When /^I allocate \$(\d+) in Round (\d+)$/, (funds, round, next) ->
    next.pending()

  @Then /^User "([^"]*)" should have \$(\d+) for Round (\d+)$/, (username, funds, round, next) ->
    next.pending()

  @Then /^Round (\d+) should show \$(\d+) allocated$/, (round, funds, next) ->
    next.pending()

  @When /^I allocated \$(-?\d+) in Round (\d+)$/, (funds, round, next) ->
    next.pending()

  @Then /^User "([^"]*)" should have \$(\d+) for Round  (\d+)$/, (username, funds, round, next) ->
    next.pending()
