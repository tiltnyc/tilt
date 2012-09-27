BaseController  = require './base_controller'
Result          = require '../../models/result'
Round           = require '../../models/round'

class ResultsController extends BaseController

  index: (request, response) ->
    if !request.currentEvent
      return response.render 'results/index',
        title: 'Current Results'
    query = 
      event: request.currentEvent.id
    if request.round
      query.round = request.round.id 

    Result.find(query).populate('round', null, {},
      sort: 'number'
    ).populate('team', null, {},
      sort: 'name'
    ).exec (err, results) =>
      return @error(request, response, err, '/') if err
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
      Round.find(event: request.currentEvent.id).sort("number","descending").exec (err, rounds) ->

        if request.params.format is 'json'
          response.contentType 'application/json'
          response.send JSON.stringify(roundResults)
        else
          lastResultRound = 1
          lastResultRound = (if (request.currentRound.processed) then request.currentRound.number else Math.max(request.currentRound.number - 1, 1))  if request.currentRound
          roundResults.reverse()      
          response.render 'results/index',
            title: if query.round? then "Round #{request.round.number} Results" else 'Current Results'
            results: roundResults
            rounds: rounds
            round: request.round  
            isCurrent: !query.round?
            lastResultRound: lastResultRound
            currentRound: request.currentRound


module.exports = ResultsController