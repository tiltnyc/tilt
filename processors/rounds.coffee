Investment = require("../models/investment")
Transaction = require("../models/transaction")
User = require("../models/user")
Team = require("../models/team")
Round = require("../models/round")
Result = require("../models/result")

process = (round, done) ->
  results = {}
  total = 0
  investerList = []
  average = 0
  averagePercentage = 0
  cumulativeDistanceFromAverage = 0
  factor = 0

  saveResults = (data, index, callback) ->
    return callback() if Object.keys(data).length is index
    teamId = Object.keys(data)[index]
    team = data[teamId].team
    teamPercentage = if total > 0 then data[teamId].result / total else 0
    teamPriceMovement = ((teamPercentage - averagePercentage) * factor)
    before_price = team.last_price
    teamPriceMovement = (teamPercentage - averagePercentage)  if teamPriceMovement < 0
    cumulativeDistanceFromAverage += Math.abs(teamPercentage - averagePercentage)
    #console.log "team: " + team.name + " got: " + teamPercentage
    #console.log "resulting in: " + Math.roundToFixed(teamPriceMovement, 2)
    team.last_price += teamPriceMovement
    team.movement = teamPriceMovement
    team.movement_percentage = if before_price isnt 0 then teamPriceMovement / before_price else 0
    team.save (err, team) ->
      return callback(err) if err
      new Result(
        team: team.id
        round: round.id
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
        fundsInRound = investment.user.getFundsForRoundNbr(round.number)
        investedInTeam = investment.percentage * fundsInRound
        investmentReturnForTeam = investedInTeam * results[investment.team.id].team.last_price
        new Transaction(
          user: investment.user.id
          round: round.number + 1
          label: "return for round " + round.number + " investment in team: " + investment.team.name
          amount: investmentReturnForTeam
        ).save (err) ->
          return callback(err) if err
          rewardUsersForInvestments investments, index + 1, callback
      else
        rewardUsersForInvestments investments, index + 1, callback
    else callback()

  Team.find().exec (err, teams) ->
    return done err if err
    teamCount = teams.length

    teams.forEach (team) -> #preset results to 0 for each team
      results[team.id] =
        team: team
        result: 0

    Round.findOne(number: 1).exec (err, firstRound) -> #load first round
      return done err if err

      Investment.find(round: round.number).populate("user").populate("team").exec (err, investments) ->
        return done err if err
        investments.forEach (investment) ->
          userInvested = investment.percentage * investment.user.getFundsForRoundNbr(round.number)
          results[investment.team.id].result += userInvested
          total += userInvested
          investerList.push investment.user.id unless investerList.indexOf(investment.user.id) >= 0

        average = total / teamCount
        averagePercentage = if total > 0 then average / total else 0
        factor = if round.is_first or Number(firstRound.total_funds) is 0 then 1 else total / firstRound.total_funds
        #console.log results
        #console.log "total Invested: " + total
        #console.log "number of total teams: " + teamCount
        #console.log "average Investment: " + average
        #console.log "average As Percentage: " + averagePercentage
        #console.log "number of investors: " + investerList.length
        #console.log "factor: " + factor

        saveResults results, 0, (err) ->
          return done err if err
          round.standard_deviation = cumulativeDistanceFromAverage / teamCount
          round.total_funds = total
          round.investor_count = investerList.length
          round.average = averagePercentage
          round.factor = factor
          #console.log "sd= " + round.standard_deviation
          round.is_open = false
          round.save (err) ->
            return done err if err
            rewardUsersForInvestments investments, 0, (err) ->
              return done err if err
              done()

module.exports =
  process: process
