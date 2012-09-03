{mongoose, Schema, ObjectId} = require("./db_connect")

User = require("./user")

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
    #required: true JM: uncomment when ready

  round:
    type: Number
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
  transaction = this
  User.findOne
    _id: @user
  , (err, user) ->
    return next(err) if err
    user.addFundsForRoundNbr transaction.round, transaction.amount
    user.save (err) ->
      if err
        next err
      else
        next()

exports = module.exports = mongoose.model("Transaction", Transaction)