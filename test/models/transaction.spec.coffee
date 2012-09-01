{should, clean, factory} = require "../test-base"

Transaction = require "../../models/transaction"
User = require "../../models/user"
  
describe "Transaction", ->
  user = undefined
  event = undefined

  beforeEach (done) ->
    factory.starter 1, (result) ->
      user = result.users[0]
      event = result.event 
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
          user.getFundsForRoundNbr(round).should.eql total
          next()

    createAndTest 1, 105, 105, () ->
      createAndTest 1, 200, 305, () ->
        createAndTest 1, -50, 255, () ->
          createAndTest 2, 10, 10, () -> 
            createAndTest 5, 15, 15, () -> #test round out of bounds
              done()