{should, clean, factory} = require "../test-base"

Allocation = require "../../processors/allocation"
User = require "../../models/user"
Round = require "../../models/round" 

describe "Allocation Process", ->
  userA = undefined
  userB = undefined
  round = undefined
  event = undefined

  beforeEach (done) ->
    factory.starter 2, (result) ->
      userA = result.users[0]
      userB = result.users[1]
      round = result.rounds[1]
      event = result.event
      userB.funds = [0, 150, 312.23]
      userB.save (err, user) ->
        throw err if err
        done()

  afterEach (done) -> clean done

  it "must allocate money to all users within a specific round", (done) ->
    Allocation.process event, round, 100, (err) ->
      throw err if err
      User.findById userA, (err, user) ->
        user.getFundsForRoundNbr(round.number).should.eql(100)
        User.findById userB, (err, user) ->
          user.getFundsForRoundNbr(round.number).should.eql(250)
          done()

  it "must allocate negatively also", (done) ->
    Allocation.process event, round, -100, (err) ->
      throw err if err
      User.findById userA, (err, user) ->
        user.getFundsForRoundNbr(round.number).should.eql(-100)
        User.findById userB, (err, user) ->
          user.getFundsForRoundNbr(round.number).should.eql(50)
          done()