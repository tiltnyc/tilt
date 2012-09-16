{mongoose, Schema, ObjectId} = require("./db_connect")

User = require("./user")
Round = require("./round")

Transaction = new Schema
  amount:
    type: Number
    required: true

  user:
    type: ObjectId
    ref: "User"
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
    User.findById(transaction.user).exec (err, user) ->
      return next(err) if err
      user.addFundsForRoundNbr round, transaction.amount
      user.save (err) ->
        return next err if err
        next()

exports = module.exports = mongoose.model("Transaction", Transaction)