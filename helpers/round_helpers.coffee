Round = require("../models/round")
exports.loadCurrentRound = (req, res, next) ->
  Round.findOne(event: req.currentEvent.id, is_current: true).exec (err, round) ->
    return next(err) if err
    req.currentRound = round
    next()

exports.loadFirstRound = (req, res, next) ->
  Round.findOne(event: req.currentEvent.id, number: 1).exec (err, round) ->
    return next(err) if err
    req.firstRound = round
    next()

exports.getOrCreateNextRound = (round, done) ->
  number = round.number + 1
  Round.findOne(event: round.event, number: number).exec (err, nextRound) -> 
    return done err if err
    return done null, nextRound if nextRound
    new Round
      number: number
      event: round.event
    .save (err, round) ->
      return done err if err
      done null, round