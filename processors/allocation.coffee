User = require "../models/user"
Transaction = require "../models/transaction"

process = (round, amount, done) ->
  stream = User.find().stream()
  number = round.number
  stream.on "data", (user) ->
    stream.pause()
    new Transaction(
      amount: amount
      round: number
      user: user.id
      label: "round " + number.toString() + " allocation."
    ).save (err, doc) ->
      return done err if err
      stream.resume()

  stream.on "error", (err) ->
    stream.destroy()
    return done err if err

  stream.on "close", ->
    round.allocated += amount
    round.save (err) ->
      return done err if err
      done()

exports.process = process