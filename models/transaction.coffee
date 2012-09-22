{mongoose, Schema, ObjectId} = require("./db_connect")

Investor = require("./investor")
Round = require("./round")

Transaction = new Schema
  amount:
    type: Number
    required: true

  investor:
    type: ObjectId
    ref: "Investor"
    required: true

  event:
    type: ObjectId
    ref: "Event"
    required: true 

  round:
    type: ObjectId
    ref: "Round"
    required: true

  label:
    type: String

  created_at:
    type: Date
    default: Date.now

  updated_at:
    type: Date
    default: Date.now

Transaction.pre "save", (next) ->
  transaction = @
  Round.findById(transaction.round).exec (err, round) ->
    return next(err) if err
    Investor.findById(transaction.investor).exec (err, investor) ->
      return next(err) if err
      investor.addFundsForRoundNbr round.number, transaction.amount
      investor.save (err) ->
        return next err if err
        next()

exports = module.exports = mongoose.model("Transaction", Transaction)