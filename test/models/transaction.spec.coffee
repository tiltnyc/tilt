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

  it "on save, appends funds to user for specified round", (done) ->
   
    createAndTest = (round, amount, total, next) ->
      transaction = new Transaction
        user: user._id
        amount: amount
        round: round
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
            done()