{mongoose, Schema, ObjectId} = require("./db_connect")
Transaction = new Schema(
  amount:
    type: Number
    required: true

  user:
    type: ObjectId
    ref: "User"
    required: true

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
)
User = require("./user")
Transaction.pre "save", (next) ->
  transaction = this
  User.findOne
    _id: @user
  , (err, user) ->
    return next(err)  if err
    funds = user.funds.concat()
    funds[transaction.round - 1] = 0  unless funds[transaction.round - 1]
    funds[transaction.round - 1] += transaction.amount
    user.funds = funds
    user.save (err) ->
      if err
        next err
      else
        next()

exports = module.exports = mongoose.model("Transaction", Transaction)