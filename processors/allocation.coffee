Investor = require "../models/investor"
Transaction = require "../models/transaction"

process = (event, round, amount, done) ->
  stream = Investor.find({event: event.id}).stream()
  number = round.number
  stream.on "data", (investor) ->
    stream.pause()
    new Transaction(
      amount: amount
      round: round.id
      investor: investor.id
      event: event.id
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