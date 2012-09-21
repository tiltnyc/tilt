{should, clean, factory} = require "../test-base"

Transaction = require "../../models/transaction"
Competitor = require "../../models/competitor"
  
describe "Transaction", ->
  user = undefined
  competitor = undefined
  event = undefined
  round1 = undefined
  round2 = undefined

  beforeEach (done) ->
    factory.starter 2, (result) ->
      user = result.users[0]
      competitor = result.competitors[0]
      event = result.event 
      round1 = result.rounds[0]
      round2 = result.rounds[1]
      done()

  afterEach (done) ->
    clean done

  it "on save, appends funds to user for specified round", (done) ->
   
    createAndTest = (round, amount, total, next) ->
      transaction = new Transaction
        competitor: competitor
        amount: amount
        round: round
        event: event
      transaction.save (err) ->
        throw err if err
        Competitor.findById(competitor.id).exec (err, competitor) ->
          competitor.getFundsForRoundNbr(round.number).should.eql total
          next()

    createAndTest round1, 105, 105, () ->
      createAndTest round1, 200, 305, () ->
        createAndTest round1, -50, 255, () ->
          createAndTest round2, 10, 10, () -> 
            done()