{should, clean, create} = require "../test-base"

Rounds = require "../../processors/rounds"
Allocation = require "../../processors/allocation"

Investment = require "../../models/investment"
Result = require "../../models/result"
User = require "../../models/user"
Team = require "../../models/team"
Round = require "../../models/round"

describe "Round Process", ->
  userA = undefined
  userB = undefined
  userC = undefined
  teamA = undefined
  teamB = undefined
  teamC = undefined
  teamD = undefined
  round1 = undefined
  round2 = undefined

  beforeEach (done) ->
    userA = create User, {name: 'justin', email: 'j@example.com'}, () ->
      userB = create User, {name: 'paul', email: 'p@example.com'}, () ->
        userC = create User, {name: 'fred', email: 'f@example.com'}, () ->
          teamA = create Team, name: 'teamA', () ->
            teamB = create Team, name: 'teamB', () ->
              teamC = create Team, name: 'teamC', () ->
                teamD = create Team, name: 'teamD', () ->
                  round1 = create Round, number: 1,  () ->
                    round2 = create Round, number: 2, () ->
                      done()

  afterEach (done) -> clean done

  invest = (user, round, team, percentage, done) ->
    create Investment,
      user: user.id
      team: team.id
      round: round.number
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

  checkReward = (user, round, expected, done) ->
    User.findById(user.id).exec (err, user) ->
      throw err if err
      Math.roundToFixed(user.getFundsForRoundNbr(round.number + 1), 2).should.eql expected
      done()

  goRoundOne = (done) ->
    Allocation.process round1, 100, (err) ->
      throw err if err
      invest userA, round1, teamA, 0.6, () ->
        invest userA, round1, teamB, 0.4, () ->
          invest userB, round1, teamA, 0.25, () ->
            invest userB, round1, teamB, 0.25, () ->
              invest userB, round1, teamC, 0.5, () ->
                Rounds.process round1, (err) ->
                  throw err if err
                  done()


  goRoundTwo = (done) ->
    Allocation.process round2, 250, (err) ->
      throw err if err
      invest userA, round2, teamA, 1, () ->
        invest userB, round2, teamA, 0.1, () ->
          invest userB, round2, teamB, 0.9, () ->
            invest userC, round2, teamD, 0.35, () ->
              invest userC, round2, teamC, 0.65, () ->
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
      checkReward userA, round1, 113.5, () ->
        checkReward userB, round1, 106.25, () ->
          checkReward userC, round1, 0, () ->
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
        checkReward userA, round2, 711.89, () ->
          checkReward userB, round2, 539.79, () ->
            checkReward userC, round2, 200.75, () ->
              done()
