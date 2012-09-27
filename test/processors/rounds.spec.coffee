{should, clean, factory} = require "../test-base"

Rounds = require "../../processors/rounds"
Allocation = require "../../processors/allocation"

Investment = require "../../models/investment"
Result = require "../../models/result"
Investor = require "../../models/investor"
Team = require "../../models/team"
Round = require "../../models/round"
Vote = require "../../models/vote"

describe "Round Process", ->
  all = undefined
  userA = undefined
  userB = undefined
  userC = undefined
  investorA = undefined
  investorB = undefined
  investorC = undefined
  teamA = undefined
  teamB = undefined
  teamC = undefined
  teamD = undefined
  round1 = undefined
  round2 = undefined
  event = undefined

  beforeEach (done) ->
    factory.starter 
      users: 24
      competitors: 24
      teams: 4
      rounds: 3
      investors: 4
    , (result) ->
      all = result
      userA = result.users[0]
      userB = result.users[1]
      userC = result.users[2]
      investorA = result.investors[0]
      investorB = result.investors[1]
      investorC = result.investors[2]
      teamA = result.teams[0]
      teamB = result.teams[1]
      teamC = result.teams[2]
      teamD = result.teams[3]
      round1 = result.rounds[0]
      round2 = result.rounds[1]
      event = result.event
      done()

  afterEach (done) -> clean done

  invest = (investor, round, team, percentage, done) ->
    factory.create Investment,
      investor: investor.id
      team: team.id
      round: round.id
      event: event.id
      percentage: percentage
    , () -> done()

  checkResult = (team, round, rank, before_price, percentage_score, movement, movement_percentage, after_price, done) ->
    Result.findOne
      team: team
      round: round
    .populate("team")
    .exec (err, result) ->
      throw err if err
      result.team.rank.should.eql rank
      Math.roundToFixed(result.before_price, 3).should.eql before_price
      Math.roundToFixed(result.percentage_score, 3).should.eql percentage_score
      Math.roundToFixed(result.movement, 3).should.eql movement
      Math.roundToFixed(result.team.movement, 3).should.eql movement
      Math.roundToFixed(result.movement_percentage, 3).should.eql movement_percentage
      Math.roundToFixed(result.team.movement_percentage, 3).should.eql movement_percentage
      Math.roundToFixed(result.after_price, 3).should.eql after_price
      Math.roundToFixed(result.team.last_price, 3).should.eql after_price
      done()

  checkReward = (investor, round, expected, done) ->
    Investor.findById(investor.id).exec (err, investor) ->
      throw err if err
      Math.roundToFixed(investor.getFundsForRoundNbr(round.number + 1), 2).should.eql expected
      done()

  goRoundOne = (done) ->
    Allocation.process event, round1, 100, (err) ->
      throw err if err
      invest investorA, round1, teamA, 0.6, () ->
        invest investorA, round1, teamB, 0.4, () ->
          invest investorB, round1, teamA, 0.25, () ->
            invest investorB, round1, teamB, 0.25, () ->
              invest investorB, round1, teamC, 0.5, () ->
                Rounds.process round1, (err) ->
                  throw err if err
                  done()


  goRoundTwo = (done) ->
    Allocation.process event, round2, 250, (err) ->
      throw err if err
      invest investorA, round2, teamA, 1, () ->
        invest investorB, round2, teamA, 0.1, () ->
          invest investorB, round2, teamB, 0.9, () ->
            invest investorC, round2, teamD, 0.35, () ->
              invest investorC, round2, teamC, 0.65, () ->
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
        checkResult teamA, round1, 1, 1, 0.425, 0.175, 0.175, 1.175, () ->
          checkResult teamB, round1, 2, 1, 0.325, 0.075, 0.075, 1.075, () ->
            checkResult teamC, round1, 3, 1, 0.25, 0, 0, 1, () ->
              checkResult teamD, round1, 4, 1, 0, -0.25, -0.25, 0.75, () ->
                done()

  it "must reward investors for round 1", (done) ->
    goRoundOne () ->
      checkReward investorA, round1, 113.5, () ->
        checkReward investorB, round1, 106.25, () ->
          checkReward investorC, round1, 0, () ->
            done()

  it "must valuate teams for round 2", (done) ->
    goRoundOne () ->
      goRoundTwo () ->
        Round.findById(round2.id).exec (err, round) ->
          throw err if err
          Math.roundToFixed(round.standard_deviation, 3).should.eql 0.121
          round.processed.should.eql true
          Math.roundToFixed(round.factor, 3).should.eql 4.849
          checkResult teamA, round2, 1, 1.175, 0.412, 0.783, 0.667, 1.958, () ->
            checkResult teamB, round2, 2, 1.075, 0.331, 0.391, 0.364, 1.466, () ->
              checkResult teamC, round2, 3, 1, 0.168, -0.082, -0.082, 0.918, () ->
                checkResult teamD, round2, 4, 0.75, 0.09, -0.160, -0.213, 0.59, () ->
                  done()

  it "must reward investors for round 2", (done) ->
    goRoundOne () ->
      goRoundTwo () ->
        checkReward investorA, round2, 711.89, () ->
          checkReward investorB, round2, 539.79, () ->
            checkReward investorC, round2, 200.75, () ->
              done()

  describe "Votes", () ->
    teamE = undefined
    teamF = undefined
    beforeEach (done) ->
      factory.create Team,
        name: "team E"
        event: event.id
      , (team) ->
        teamE = team
        factory.create Team,
          name: "team F"
          event: event.id
        , (team) ->
          teamF = team
          done()

    vote = (competitor, round, teams, done) ->
      doVote = (i, complete) ->
        return complete() if i >= teams.length
        team = teams[i]
        factory.create Vote,
          competitor: competitor.id
          team: team.id
          round: round.id
          event: event.id
        , () -> doVote i+1, complete
      doVote 0, () -> done() 

    voteSet = (round, matrix, done) ->
      doSet = (i, complete) ->
        return complete() if i >= matrix.length
        row = matrix[i]
        vote all.competitors[i], round, row, () -> doSet i+1, complete
      doSet 0, () -> done()

    checkVoteResult = (team, round, rank, votes, votePercent, voteMovement, done) ->
      Result.findOne
        team: team
        round: round
      .populate("team")
      .exec (err, result) ->
        throw err if err
        result.vote_count.should.eql votes
        result.team.rank.should.eql rank
        Math.roundToFixed(result.vote_percentage, 3).should.eql votePercent
        Math.roundToFixed(result.vote_movement, 3).should.eql voteMovement
        done()

    goVoteRoundOne = (done) ->
      voteSet round1, [
        [teamA, teamB, teamC], [teamA, teamB, teamC], [teamA, teamB, teamC]
      , [teamA, teamB, teamC], [teamA, teamB, teamC], [teamA, teamB, teamC]
      , [teamA, teamB, teamC], [teamA, teamB, teamC], [teamA, teamB, teamE]
      , [teamA, teamB, teamE], [teamA, teamB, teamE], [teamA, teamB, teamE]
      , [teamD, teamF, teamE], [teamD, teamF, teamE], [teamD, teamF, teamE]
      , [teamD, teamF, teamE], [teamD, teamF, teamE], [teamD, teamA, teamE]
      , [teamD, teamF, teamE], [teamD, teamF, teamE], [teamD, teamF, teamE]
      , [teamD, teamB, teamE], [teamD, teamB, teamE], [teamA, teamB, teamE]
      ], () -> done()

    it "must calculate votes for round 1", (done) ->
      goVoteRoundOne () ->         
        Rounds.process round1, (err) ->
          checkVoteResult teamA, round1, 3, 14, 0.7, 0.1, () ->
            checkVoteResult teamB, round1, 2, 15, 0.75, 0.15, () ->
              checkVoteResult teamC, round1, 5, 8, 0.4, -0.2, () ->
                checkVoteResult teamD, round1, 4, 11, 0.55, -0.05, () ->
                  checkVoteResult teamE, round1, 1, 16, 0.8, 0.2, () ->
                    checkVoteResult teamF, round1, 5, 8, 0.4, -0.2, () ->
                      Round.findById(round1.id).exec (err, round) ->
                        throw err if err
                        round.vote_count.should.eql 72
                        round.average_team_votes.should.eql 12
                        done()

    it "must calculate votes and investments together", (done) ->
      goVoteRoundOne () ->
        goRoundOne () ->
          ###checkResult teamA, round1, 1, 0.425, 0.175, 0.175, 1.175, () ->
            checkResult teamB, round1, 1, 0.325, 0.075, 0.075, 1.075, () ->
              checkResult teamC, round1, 1, 0.25, 0, 0, 1, () ->
                checkResult teamD, round1, 1, 0, -0.25, -0.25, 0.75, () ->
                  done()###
          done()