Competitor = require "../models/competitor"
Transaction = require "../models/transaction"

process = (event, round, amount, done) ->
  stream = Competitor.find({event: event.id}).stream()
  number = round.number
  stream.on "data", (competitor) ->
    stream.pause()
    new Transaction(
      amount: amount
      round: round.id
      competitor: competitor.id
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