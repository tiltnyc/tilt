Investment = require("../models/investment")
Transaction = require("../models/transaction")
User = require("../models/user")
Team = require("../models/team")
Round = require("../models/round")
RoundHelpers = require("../helpers/round_helpers")
Result = require("../models/result")
Vote = require("../models/vote")

process = (round, done) ->
  results = {}
  total = 0
  investerList = []
  average = 0
  averagePercentage = 0
  cumulativeDistanceFromAverage = 0
  factor = 0
  nextRound = undefined
  totalVotes = 0
  competitorsPerTeam = 4
  voterList = []
  averageVotes = 0
  averageVotePercent = 0

  saveResults = (data, index, callback) ->
    return callback() if Object.keys(data).length is index
    teamId = Object.keys(data)[index]
    team = data[teamId].team
    teamPercentage = if total > 0 then data[teamId].result / total else 0
    teamPriceMovement = ((teamPercentage - averagePercentage) * factor)
    before_price = team.last_price
    teamPriceMovement = (teamPercentage - averagePercentage)  if teamPriceMovement < 0
    cumulativeDistanceFromAverage += Math.abs(teamPercentage - averagePercentage)
    team.last_price += teamPriceMovement
    team.movement = teamPriceMovement
    team.movement_percentage = if before_price isnt 0 then teamPriceMovement / before_price else 0
    team.save (err, team) ->
      return callback(err) if err
      new Result(
        team: team.id
        round: round.id
        event: round.event
        before_price: before_price
        after_price: team.last_price
        movement: team.movement
        movement_percentage: team.movement_percentage
        percentage_score: teamPercentage
      ).save (err, result) ->
        return callback(err)  if err
        saveResults data, index + 1, callback

  rewardUsersForInvestments = (investments, index, callback) ->
    investment = undefined
    if investment = investments[index]
      if investment.percentage > 0
        fundsInRound = investment.investor.getFundsForRoundNbr(round.number)
        investedInTeam = investment.percentage * fundsInRound
        investmentReturnForTeam = investedInTeam * results[investment.team.id].team.last_price
        new Transaction(
          investor: investment.investor.id
          round: nextRound.id
          event: round.event
          label: "return for round " + round.number + " investment in team: " + investment.team.name
          amount: investmentReturnForTeam
        ).save (err) ->
          return callback(err) if err
          rewardUsersForInvestments investments, index + 1, callback
      else
        rewardUsersForInvestments investments, index + 1, callback
    else callback()

  Team.find(event: round.event).exec (err, teams) ->
    return done err if err
    teamCount = teams.length

    teams.forEach (team) -> #preset results to 0 for each team
      results[team.id] =
        team: team
        result: 0
        votes: 0

    Round.findOne(event: round.event, number: 1).exec (err, firstRound) -> #load first round
      return done err if err

      RoundHelpers.getOrCreateNextRound round, (err, upcomingRound) ->
        return done err if err
        nextRound = upcomingRound
        Investment.find(round: round.id).populate("investor").populate("team").exec (err, investments) ->
          return done err if err
          investments.forEach (investment) ->
            userInvested = investment.percentage * investment.investor.getFundsForRoundNbr(round.number)
            results[investment.team.id].result += userInvested
            total += userInvested
            investerList.push investment.investor.id unless investerList.indexOf(investment.investor.id) >= 0

          average = total / teamCount
          averagePercentage = if total > 0 then average / total else 0
          factor = if round.is_first or Number(firstRound.total_funds) is 0 then 1 else total / firstRound.total_funds

          #process votes
          Vote.find(round: round.id).populate("competitor").populate("team").exec (err, votes) ->
            return done err if err
            bestVoteScore = (teamCount - 1) * competitorsPerTeam #JM: this is rough - not always 4 team members
            votes.forEach (vote) ->
              results[vote.team.id].votes++
              totalVotes++
              voterList.push vote.competitor.id unless voterList.indexOf(vote.competitor.id) >= 0

            averageVotes = totalVotes / teamCount
            averageVotePercent = averageVotes / bestVoteScore

            for key, r of results
              r.votePercent = r.votes / bestVoteScore
              r.voteMovement = r.votePercent - averageVotePercent

            saveResults results, 0, (err) ->
              return done err if err
              round.standard_deviation = cumulativeDistanceFromAverage / teamCount
              round.total_funds = total
              round.investor_count = investerList.length
              round.average = averagePercentage
              round.factor = factor
              round.is_open = false
              round.save (err) ->
                return done err if err
                rewardUsersForInvestments investments, 0, (err) ->
                  return done err if err
                  done()

module.exports =
  process: process
