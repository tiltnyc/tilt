{mongoose, Schema, ObjectId} = require("./db_connect")

mongooseAuth = require("mongoose-auth")

Investor = new Schema(
  user:
    type: ObjectId
    ref: "User"
    required: true

  event:
    type: ObjectId 
    ref:  "Event"
    required: true

  funds:
    type: [ Number ]
    default: []

  created_at:
    type: Date
    default: Date.now

  updated_at:
    type: Date
    default: Date.now
)

Investor.methods.getFundsForRoundNbr = (roundNbr) ->
  @funds[roundNbr - 1] ? 0

Investor.methods.addFundsForRoundNbr = (roundNbr, funds) ->
  i = roundNbr - 1
  _funds = @funds.concat()
  x = 0
  _funds[x++] ?= 0 while x < roundNbr #ensure funds for previous rounds initialised
  _funds[i] += funds
  @funds = _funds

exports = module.exports = mongoose.model("Investor", Investor)