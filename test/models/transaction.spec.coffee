{should, clean, factory} = require "../test-base"

Transaction = require "../../models/transaction"
User = require "../../models/user"
  
describe "Transaction", ->
  user = undefined
  event = undefined
  round1 = undefined
  round2 = undefined

  beforeEach (done) ->
    factory.starter 1, (result) ->
      user = result.users[0]
      event = result.event 
      round1 = result.rounds[0]
      round2 = result.rounds[1]
      done()

  afterEach (done) ->
    clean done

  it "on save, appends funds to user for specified round", (done) ->
   
    createAndTest = (round, amount, total, next) ->
      transaction = new Transaction
        user: user
        amount: amount
        round: round
        event: event
      transaction.save (err) ->
        throw err if err
        User.findOne
          _id: user._id
        , (err, user) ->
          user.getFundsForRoundNbr(round.number).should.eql total
          next()

    createAndTest round1, 105, 105, () ->
      createAndTest round1, 200, 305, () ->
        createAndTest round1, -50, 255, () ->
          createAndTest round2, 10, 10, () -> 
            done()