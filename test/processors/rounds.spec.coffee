{should, clean, factory} = require "../test-base"

Rounds = require "../../processors/rounds"
Allocation = require "../../processors/allocation"

Investment = require "../../models/investment"
Result = require "../../models/result"
Competitor = require "../../models/competitor"
Team = require "../../models/team"
Round = require "../../models/round"

describe "Round Process", ->
  userA = undefined
  userB = undefined
  userC = undefined
  competitorA = undefined
  competitorB = undefined
  competitorC = undefined
  teamA = undefined
  teamB = undefined
  teamC = undefined
  teamD = undefined
  round1 = undefined
  round2 = undefined
  event = undefined

  beforeEach (done) ->
    factory.starter 4, (result) ->
      userA = result.users[0]
      userB = result.users[1]
      userC = result.users[2]
      competitorA = result.competitors[0]
      competitorB = result.competitors[1]
      competitorC = result.competitors[2]
      teamA = result.teams[0]
      teamB = result.teams[1]
      teamC = result.teams[2]
      teamD = result.teams[3]
      round1 = result.rounds[0]
      round2 = result.rounds[1]
      event = result.event
      done()

  afterEach (done) -> clean done

  invest = (competitor, round, team, percentage, done) ->
    factory.create Investment,
      competitor: competitor.id
      team: team.id
      round: round.id
      event: event.id
      percentage: percentage
    , () -> done()

  checkResult = (team, round, before_price, percentage_score, movement, movement_percentage, after_price, done) ->
    Result.findOne
      team: team
      round: round
    .populate("team")
    .exec (err, result) ->
      throw err if err
      Math.roundToFixed(result.before_price, 3).should.eql before_price
      Math.roundToFixed(result.percentage_score, 3).should.eql percentage_score
      Math.roundToFixed(result.movement, 3).should.eql movement
      Math.roundToFixed(result.team.movement, 3).should.eql movement
      Math.roundToFixed(result.movement_percentage, 3).should.eql movement_percentage
      Math.roundToFixed(result.team.movement_percentage, 3).should.eql movement_percentage
      Math.roundToFixed(result.after_price, 3).should.eql after_price
      Math.roundToFixed(result.team.last_price, 3).should.eql after_price
      done()

  checkReward = (competitor, round, expected, done) ->
    Competitor.findById(competitor.id).exec (err, competitor) ->
      throw err if err
      Math.roundToFixed(competitor.getFundsForRoundNbr(round.number + 1), 2).should.eql expected
      done()

  goRoundOne = (done) ->
    Allocation.process event, round1, 100, (err) ->
      throw err if err
      invest competitorA, round1, teamA, 0.6, () ->
        invest competitorA, round1, teamB, 0.4, () ->
          invest competitorB, round1, teamA, 0.25, () ->
            invest competitorB, round1, teamB, 0.25, () ->
              invest competitorB, round1, teamC, 0.5, () ->
                Rounds.process round1, (err) ->
                  throw err if err
                  done()


  goRoundTwo = (done) ->
    Allocation.process event, round2, 250, (err) ->
      throw err if err
      invest competitorA, round2, teamA, 1, () ->
        invest competitorB, round2, teamA, 0.1, () ->
          invest competitorB, round2, teamB, 0.9, () ->
            invest competitorC, round2, teamD, 0.35, () ->
              invest competitorC, round2, teamC, 0.65, () ->
                Rounds.process round2, (err) ->
                  throw err if err
                  done()


  it "must valuate teams for round 1", (done) ->
    goRoundOne () ->
      Round.findById(round1.id).exec (err, round) ->
        throw err if err
        round.factor.should.eql 1
        round.standard_deviation.should.eql 0.125
        round.processed.should.eql true
        checkResult teamA, round1, 1, 0.425, 0.175, 0.175, 1.175, () ->
          checkResult teamB, round1, 1, 0.325, 0.075, 0.075, 1.075, () ->
            checkResult teamC, round1, 1, 0.25, 0, 0, 1, () ->
              checkResult teamD, round1, 1, 0, -0.25, -0.25, 0.75, () ->
                done()

  it "must reward investors for round 1", (done) ->
    goRoundOne () ->
      checkReward competitorA, round1, 113.5, () ->
        checkReward competitorB, round1, 106.25, () ->
          checkReward competitorC, round1, 0, () ->
            done()

  it "must valuate teams for round 2", (done) ->
    goRoundOne () ->
      goRoundTwo () ->
        Round.findById(round2.id).exec (err, round) ->
          throw err if err
          Math.roundToFixed(round.standard_deviation, 3).should.eql 0.121
          round.processed.should.eql true
          Math.roundToFixed(round.factor, 3).should.eql 4.849
          checkResult teamA, round2, 1.175, 0.412, 0.783, 0.667, 1.958, () ->
            checkResult teamB, round2, 1.075, 0.331, 0.391, 0.364, 1.466, () ->
              checkResult teamC, round2, 1, 0.168, -0.082, -0.082, 0.918, () ->
                checkResult teamD, round2, 0.75, 0.09, -0.160, -0.213, 0.59, () ->
                  done()

  it "must reward investors for round 2", (done) ->
    goRoundOne () ->
      goRoundTwo () ->
        checkReward competitorA, round2, 711.89, () ->
          checkReward competitorB, round2, 539.79, () ->
            checkReward competitorC, round2, 200.75, () ->
              done()
