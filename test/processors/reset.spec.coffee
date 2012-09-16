{should, clean, factory} = require "../test-base"

Reset = require "../../processors/reset"
Rounds = require "../../processors/rounds"
Allocation = require "../../processors/allocation"

Investment = require "../../models/investment"
Result = require "../../models/result"
User = require "../../models/user"
Transaction = require "../../models/transaction"
Team = require "../../models/team"
Round = require "../../models/round" 

describe "Reset Process", ->
  userA = undefined
  userB = undefined
  teamA = undefined
  teamB = undefined
  round1 = undefined
  round2 = undefined
  event = undefined

  invest = (user, round, team, percentage, done) ->
    factory.create Investment, 
      user: user.id
      team: team.id
      round: round.id
      event: event.id
      percentage: percentage
    , () -> done()

  beforeEach (done) ->
    factory.starter 2, (result) ->
      userA = result.users[0]
      userB = result.users[1]
      teamA = result.teams[0]
      teamB = result.teams[1]
      round1 = result.rounds[0]
      round2 = result.rounds[1]
      event = result.event

      invest userA, round1, teamA, 0.6, () ->
        invest userA, round1, teamB, 0.4, () ->
          invest userB, round1, teamA, 1, () ->
            Allocation.process event, round1, 100, (err) ->
              Rounds.process round1, (err) -> 
                throw err if err
                invest userA, round2, teamA, 1, () ->
                  invest userB, round2, teamB, 1, () ->
                    Allocation.process event, round2, 200, (err) ->
                      Rounds.process round2, (err) ->  
                        throw err if err
                        done()

  afterEach (done) -> clean done

  it "must wipe all user funds", (done) ->
    Reset.process event, (err) ->
      throw err if err
      User.findById(userA.id).exec (err, user) ->
        throw err if err
        user.getFundsForRoundNbr(1).should.eql 0
        user.getFundsForRoundNbr(2).should.eql 0
        User.findById(userB.id).exec (err, user) ->
          throw err if err
          user.getFundsForRoundNbr(1).should.eql 0
          user.getFundsForRoundNbr(2).should.eql 0
          done()

  it "must unprocess all rounds", (done) ->
    check = (round, callback) ->
      Round.findById(round.id).exec (err, round) ->
        throw err if err
        round.processed.should.eql false
        should.not.exist(round.standard_deviation)
        round.total_funds.should.eql 0
        round.investor_count.should.eql 0
        round.factor.should.eql 1
        round.average.should.eql 0
        round.is_open.should.eql false
        round.is_current.should.eql(Number(round.number) is 1)
        callback()

    Reset.process event, (err) ->
      throw err if err
      check round1, () ->
        check round2, () ->
          done()

  it "must remove all investments", (done) ->
    Reset.process event, (err) ->
      throw err if err
      Investment.find().exec (err, investments) ->
        throw err if err
        investments.length.should.eql 0
        done()

  it "must remove all transactions", (done) ->
    Reset.process event, (err) ->
      throw err if err
      Transaction.find().exec (err, transactions) ->
        throw err if err
        transactions.length.should.eql 0
        done()

  it "must remove all results", (done) ->
    Reset.process event, (err) ->
      throw err if err
      Result.find().exec (err, results) ->
        throw err if err
        results.length.should.eql 0
        done()

  it "must reset all team scores", (done) ->
    check = (team, callback) ->
      Team.findById(team.id).exec (err, team) ->
        throw err if err
        team.movement.should.eql 0
        team.movement_percentage.should.eql 0
        team.last_price.should.eql 1
        callback()

    Reset.process event, (err) ->
      throw err if err
      check teamA, () ->
        check teamB, () ->
          done()


