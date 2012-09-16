Round = require("../models/round")
exports.loadCurrentRound = (req, res, next) ->
  Round.findOne(event: req.currentEvent._id, is_current: true).exec (err, round) ->
    return next(err)  if err
    req.currentRound = round
    next()

exports.loadFirstRound = (req, res, next) ->
  Round.findOne(event: req.currentEvent._id, number: 1).exec (err, round) ->
    return next(err)  if err
    req.firstRound = round
    next()