{should, clean, factory} = require "../test-base"

Allocation = require "../../processors/allocation"
Competitor = require "../../models/competitor"
Round = require "../../models/round" 

describe "Allocation Process", ->
  userA = undefined
  userB = undefined
  competitorA = undefined
  competitorB = undefined
  round = undefined
  event = undefined

  beforeEach (done) ->
    factory.starter 2, (result) ->
      userA = result.users[0]
      userB = result.users[1]
      competitorA = result.competitors[0]
      competitorB = result.competitors[1]
      round = result.rounds[1]
      event = result.event
      competitorB.funds = [0, 150, 312.23]
      competitorB.save (err) ->
        throw err if err
        done()

  afterEach (done) -> clean done

  it "must allocate money to all competitors within a specific round", (done) ->
    Allocation.process event, round, 100, (err) ->
      throw err if err
      Competitor.findById competitorA, (err, competitor) ->
        competitor.getFundsForRoundNbr(round.number).should.eql(100)
        Competitor.findById competitorB, (err, competitor) ->
          competitor.getFundsForRoundNbr(round.number).should.eql(250)
          done()

  it "must allocate negatively also", (done) ->
    Allocation.process event, round, -100, (err) ->
      throw err if err
      Competitor.findById competitorA, (err, competitor) ->
        competitor.getFundsForRoundNbr(round.number).should.eql(-100)
        Competitor.findById competitorB, (err, competitor) ->
          competitor.getFundsForRoundNbr(round.number).should.eql(50)
          done()