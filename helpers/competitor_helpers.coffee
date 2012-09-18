Competitor = require("../models/competitor")
Investment = require("../models/investment")
Transaction = require("../models/transaction")
exports.loadInvestments = (event, competitor, next) ->
  Investment.find(competitor: competitor.id).populate("team").populate("round").asc("round", "team.name").run (err, investments) ->
    return next(err)  if err
    next null, investments

exports.loadTransactions = (event, competitor, next) ->
  Transaction.find(competitor: competitor.id).populate("round").asc("round", "created").run (err, transactions) ->
    return next(err)  if err
    next null, transactions