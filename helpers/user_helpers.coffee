User = require("../models/user")
Investment = require("../models/investment")
Transaction = require("../models/transaction")
exports.loadInvestments = (event, user, next) ->
  Investment.find(event: event.id, user: user.id).populate("team").populate("round").asc("round", "team.name").run (err, investments) ->
    return next(err)  if err
    next null, investments

exports.loadTransactions = (event, user, next) ->
  Transaction.find(event: event.id, user: user.id).populate("round").asc("round", "created").run (err, transactions) ->
    return next(err)  if err
    next null, transactions

exports.populate = (model, done) ->
  input = if model instanceof Array then model else [model]
  doProcess = (i, next) ->
    return next() if i >= input.length
    single = input[i].toObject()
    User.findById(single.user).select(["username", "picture", "fname", "lname"]).exec (err, user) ->
      single.user = user
      input[i] = single
      doProcess i+1, next
  doProcess 0, () -> 
    done()