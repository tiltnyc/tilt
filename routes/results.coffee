Result = require("../models/result")
Team = require("../models/team")
RoundHelpers = require("../helpers/round_helpers")
module.exports = (app) ->
  app.get "/results.:format?", RoundHelpers.loadCurrentRound, (req, res) ->
    Result.find({}).populate("round", null, {},
      sort: "number"
    ).populate("team", null, {},
      sort: "name"
    ).run (err, results) ->
      roundResults = []
      results.forEach (result) ->
        singleRoundResults = []
        unless roundResults[result.round.number - 1]
          roundResults[result.round.number - 1] = singleRoundResults
        else
          singleRoundResults = roundResults[result.round.number - 1]
        singleRoundResults.push result
        singleRoundResults.sort (a, b) ->
          a.team.name > b.team.name

      if req.params.format is "json"
        res.contentType "application/json"
        res.send JSON.stringify(roundResults)
      else
        lastResultRound = 1
        lastResultRound = (if (req.currentRound.processed) then req.currentRound.number else Math.max(req.currentRound.number - 1, 1))  if req.currentRound
        roundResults.reverse()
        res.render "results/index",
          title: "Current Results"
          results: roundResults
          lastResultRound: lastResultRound
          currentRound: req.currentRound