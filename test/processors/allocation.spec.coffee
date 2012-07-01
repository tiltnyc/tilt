{should, clean, create} = require "../test-base"

Allocation = require "../../processors/allocation"
User = require "../../models/user"
Round = require "../../models/round" 

describe "Allocation Process", ->
  userA = undefined
  userB = undefined
  round = undefined

  beforeEach (done) ->
    userA = create User, {name: 'justin', email: 'j@example.com'}, () ->
      userB = create User, {name: 'paul', email: 'p@example.com', funds: [0, 150, 312.23]}, () ->
        round = create Round, number:2, () -> done()

  it "must allocate money to all users within a specific round", (done) ->
    Allocation.process round, 100, (err) ->
      throw err if err
      User.findById userA, (err, user) ->
        user.getFundsForRoundNbr(round.number).should.eql(100)
        User.findById userB, (err, user) ->
          user.getFundsForRoundNbr(round.number).should.eql(250)
          done()

  it "must allocate negatively also", (done) ->
    Allocation.process round, -100, (err) ->
      throw err if err
      User.findById userA, (err, user) ->
        user.getFundsForRoundNbr(round.number).should.eql(-100)
        User.findById userB, (err, user) ->
          user.getFundsForRoundNbr(round.number).should.eql(50)
          done()

  