BaseController  = require './base_controller'
Round           = require '../../models/round'

flash           = require '../../helpers/system_helpers'
Rounds          = require '../../processors/rounds'
Allocation      = require '../../processors/allocation'
Reset           = require '../../processors/reset'

class RoundsController extends BaseController
  
  redirect = '/rounds'

  setParam: (request, response, next, number) ->
    Round.findOne(event: request.currentEvent.id, number: number).exec (err, round) ->
      return next(err) if err
      return next(new Error('Failed loading round ' + number))  unless round
      request.round = round
      next()

  index: (request, response) ->
    Round.find({event: request.currentEvent._id}).sort("number", "ascending").exec (err, rounds) ->
      throw err if err
      response.render 'rounds/index',
        title: 'Rounds'
        rounds: rounds
        teamCount: request.teamCount
    
  append: (request, response) ->
    Round.count {event: request.currentEvent.id}, (err, numRounds) ->
      throw err if err
      isCurrentRound = (numRounds is 0)
      new Round
        number: numRounds + 1
        is_current: isCurrentRound
        event: request.currentEvent._id
      .save (err, round) ->
        throw err if err
        request.flash 'notice', 'Round appended.'
        response.redirect redirect

  delete: (request, response) ->
    round = request.round
    round.remove (err) ->
      throw err if err
      request.flash 'notice', 'Removed round'
      response.redirect redirect

  current: (request, response) ->
    Round.findOne(event: request.currentEvent._id, is_current: true).exec (err, round) ->
      if request.params.format is 'json'
        response.contentType 'application/json'
        response.send JSON.stringify(round)
      else
        response.render 'rounds/current',
          title: 'Current Round'
          round: round

  update: (request, response) ->
    round = request.round
    round.is_open = (request.body.round.is_open.toLowerCase() is 'true')  if request.body.round.is_open
    if request.body.round.next_round
      round.is_current = false
      round.is_open = false
    round.save (err) ->
      throw err if err
      if request.body.round.next_round
        Round.findOne(event: request.currentEvent._id, number: request.round.number + 1).exec (err, round) ->
          throw err if err
          round.is_current = true
          round.save (err) ->
            throw err if err
            request.flash 'notice', 'Round progressed.'
            response.redirect redirect
      else
        request.flash 'notice', 'Round toggled.'
        response.redirect redirect

  process: (request, response) ->
    return flash.error(request, response, 'cannot process again.', redirect) if request.round.processed
    Rounds.process request.round, (err) ->
      throw err if err
      request.flash 'notice', 'Round ' + request.round.number.toString() + ' processed.'
      response.redirect redirect      

  allocate: (request, response) ->
    Allocation.process request.currentEvent, request.round, new Number(request.body.allocate.amount), request.body.allocate.investor, (err) ->
      throw err if err
      msg = if request.body.allocate.investor then 'Allocated funds to one investor' else 'Allocated funds to all investors'
      request.flash 'notice', "#{msg} in round #{request.round.number.toString()}."
      response.redirect redirect

  reset: (request, response) ->
    Reset.process request.currentEvent, (err) ->
      throw err if err
      request.flash 'notice', 'tilt has been reset.'
      response.redirect redirect

module.exports = RoundsController