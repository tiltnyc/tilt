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

  invest = (user, team, percentage, done) ->
    create Investment, 
      user: user._id
      team: team._id
      round: 1
      percentage: percentage
    , () -> done()

  checkResult = (team, round, before_price, percentage_score, movement, movement_percentage, after_price, done) ->
    Result.findOne
      team: team
      round: round 
    .populate("team") 
    .exec (err, result) -> 
      throw err if err
      console.log result
      Math.roundToFixed(result.before_price, 1).should.eql before_price
      Math.roundToFixed(result.percentage_score, 3).should.eql percentage_score
      Math.roundToFixed(result.movement, 3).should.eql movement
      Math.roundToFixed(result.team.movement, 3).should.eql movement
      Math.roundToFixed(result.movement_percentage, 3).should.eql movement_percentage
      Math.roundToFixed(result.team.movement_percentage, 3).should.eql movement_percentage
      Math.roundToFixed(result.after_price, 3).should.eql after_price
      Math.roundToFixed(result.team.last_price, 3).should.eql after_price
      
      done()

  checkReward = (user, round, expected, done) ->
    User.findById(user.id).run (err, user) ->
      throw err if err
      user.getFundsForRoundNbr(round.number + 1).should.eql expected 
      done()

  goRoundOne = (done) ->
    Allocation.process round1, 100, (err) ->
      throw err if err
      invest userA, teamA, 0.6, () ->
        invest userA, teamB, 0.4, () ->
          invest userB, teamA, 0.25, () ->
            invest userB, teamB, 0.25, () ->
              invest userB, teamC, 0.5, () ->
                Rounds.process round1, (err) -> 
                  throw err if err
                  done()    


  goRoundTwo = (done) ->
    Allocation.process round2, 250, (err) ->
      throw err if err
      invest userA, teamA, 1, () ->
        invest userB, teamA, 0.1, () ->
          invest userB, teamB, 0.9, () ->
            invest userC, teamD, 0.35, () ->
              invest userC, teamC, 0.65, () ->
                Rounds.process round2, (err) -> 
                  throw err if err
                  done()    


  it "must valuate teams for round 1", (done) ->
    goRoundOne () ->
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
        #checkResult teamA, round2, 1.175, 1, 1, 1, 1, () ->
        done()

  it "must reward investors for round 2"

