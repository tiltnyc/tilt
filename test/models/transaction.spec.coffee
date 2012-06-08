{should, clean} = require "../test-base"

Transaction = require "../../models/transaction"
User = require "../../models/user"
  
describe "Trasaction", ->
  user = undefined

  beforeEach (done) ->
    user = new User
      username: 'justin'
      email: 'justin@example.com'
    user.save (err) ->
      throw err if err
      done()

  afterEach (done) ->
    clean done

  it "on save, modifies funds to user for specified round", (done) ->
    round = 1
    amount = 105
    transaction = new Transaction
      user: user._id
      amount: amount
      round: round
    transaction.save (err) ->
      throw err if err
      User.findOne
        _id: user._id
      , (err, user) ->
        user.getFundsForRoundNbr(round).should.eql amount
        done()