Competitor = require("../models/competitor")
Investment = require("../models/investment")
Transaction = require("../models/transaction")
exports.isCompetitor = (req, res, next) ->
  result = () ->
    req.flash "error", new Error("Not in event.")
    res.redirect "/"

  return result() unless req.user
  Competitor.findOne(event: req.currentEvent.id, user: req.user.id).exec (err, competitor) ->
    return next(err) if err
    return result() unless competitor
    next()

exports.loadCompetitor = (req, res, next) ->
  next() unless req.user and req.currentEvent
  Competitor.findOne(event: req.currentEvent.id, user: req.user.id).populate("team").exec (err, competitor) ->
    return next(err) if err
    req.competitor = competitor
    res.local('competingCurrent', competitor)
    next()

exports.loadInvestments = (event, competitor, next) ->
  Investment.find(competitor: competitor.id).populate("team").populate("round").asc("round", "team.name").run (err, investments) ->
    return next(err)  if err
    next null, investments

exports.loadTransactions = (event, competitor, next) ->
  Transaction.find(competitor: competitor.id).populate("round").asc("round", "created").run (err, transactions) ->
    return next(err)  if err
    next null, transactions