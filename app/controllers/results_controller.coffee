BaseController  = require './base_controller'
Result          = require '../../models/result'

class ResultsController extends BaseController

  index: (request, response) ->
    if !request.currentEvent
      return response.render 'results/index',
        title: 'Current Results'
    Result.find(event: request.currentEvent._id).populate('round', null, {},
      sort: 'number'
    ).populate('team', null, {},
      sort: 'name'
    ).exec (err, results) ->
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

      if request.params.format is 'json'
        response.contentType 'application/json'
        response.send JSON.stringify(roundResults)
      else
        lastResultRound = 1
        lastResultRound = (if (request.currentRound.processed) then request.currentRound.number else Math.max(request.currentRound.number - 1, 1))  if request.currentRound
        roundResults.reverse()      
        response.render 'results/index',
          title: 'Current Results'
          results: roundResults
          lastResultRound: lastResultRound
          currentRound: request.currentRound

module.exports = ResultsController