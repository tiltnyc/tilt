Round = require("../models/round")
exports.loadCurrentRound = (req, res, next) ->
  Round.findOne(is_current: true).run (err, round) ->
    return next(err)  if err
    req.currentRound = round
    next()

exports.loadFirstRound = (req, res, next) ->
  Round.findOne(number: 1).run (err, round) ->
    return next(err)  if err
    req.firstRound = round
    next()