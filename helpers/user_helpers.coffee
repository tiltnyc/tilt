User = require("../models/user")
Investment = require("../models/investment")
Transaction = require("../models/transaction")
exports.loadInvestments = (user, next) ->
  Investment.find(user: user._id).populate("team").populate("round").asc("round", "team.name").run (err, investments) ->
    return next(err)  if err
    next null, investments

exports.loadTransactions = (user, next) ->
  Transaction.find(user: user._id).asc("round", "created").run (err, transactions) ->
    return next(err)  if err
    next null, transactions