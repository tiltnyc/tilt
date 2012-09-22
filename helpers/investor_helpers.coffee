Investor = require "../models/investor"
Investment = require("../models/investment")
Transaction = require("../models/transaction")

exports.isInvestor = (req, res, next) ->
  result = () ->
    req.flash "error", new Error("Not investing in event.")
    res.redirect "/"

  return result() unless req.user
  Investor.findOne(event: req.currentEvent.id, user: req.user.id).exec (err, investor) ->
    return next(err) if err
    return result() unless investor or req.user.is_admin
    next()

exports.loadInvestor = (req, res, next) ->
  return next() unless req.user and req.currentEvent
  Investor.findOne(event: req.currentEvent.id, user: req.user.id).populate("team").exec (err, investor) ->
    return next(err) if err
    if investor
      req.currentInvestor = investor 
      res.local('theInvestor', investor)
    next()

exports.loadInvestments = (event, investor, next) ->
  Investment.find(investor: investor.id).populate("team").populate("round").sort("round", "ascending").sort("team.name", "ascending").exec (err, investments) ->
    return next(err)  if err
    next null, investments

exports.loadTransactions = (event, investor, next) ->
  Transaction.find(investor: investor.id).populate("round").sort("round", "ascending").sort("created", "ascending").exec (err, transactions) ->
    return next(err)  if err
    next null, transactions