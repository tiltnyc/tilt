{should, clean, factory} = require "../test-base"

Allocation = require "../../processors/allocation"
Investor = require "../../models/investor"
Round = require "../../models/round" 

describe "Allocation Process", ->
  userA = undefined
  userB = undefined
  investorA = undefined
  investorB = undefined
  round = undefined
  event = undefined

  beforeEach (done) ->
    factory.starter 2, (result) ->
      userA = result.users[0]
      userB = result.users[1]
      investorA = result.investors[0]
      investorB = result.investors[1]
      round = result.rounds[1]
      event = result.event
      investorB.funds = [0, 150, 312.23]
      investorB.save (err) ->
        throw err if err
        done()

  afterEach (done) -> clean done

  it "must allocate money to all investors within a specific round", (done) ->
    Allocation.process event, round, 100, (err) ->
      throw err if err
      Investor.findById investorA, (err, investor) ->
        investor.getFundsForRoundNbr(round.number).should.eql(100)
        Investor.findById investorB, (err, investor) ->
          investor.getFundsForRoundNbr(round.number).should.eql(250)
          done()

  it "must allocate negatively also", (done) ->
    Allocation.process event, round, -100, (err) ->
      throw err if err
      Investor.findById investorA, (err, investor) ->
        investor.getFundsForRoundNbr(round.number).should.eql(-100)
        Investor.findById investorB, (err, investor) ->
          investor.getFundsForRoundNbr(round.number).should.eql(50)
          done()