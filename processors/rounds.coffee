Investment = require("../models/investment")
Transaction = require("../models/transaction")
User = require("../models/user")
Team = require("../models/team")
Round = require("../models/round")
Result = require("../models/result")

process = (round, firstRound, teamCount, done) ->
  results = {}
  total = 0
  investerList = []
  average = 0
  averagePercentage = 0
  cumulativeDistanceFromAverage = 0
  factor = 0
  teamCount ?= 0

  saveResults = (data, index, callback) ->
    return callback() if Object.keys(data).length is index
    teamId = Object.keys(data)[index]
    team = data[teamId].team
    teamPercentage = if total > 0 then data[teamId].result / total else 0
    teamPriceMovement = ((teamPercentage - averagePercentage) * factor)
    before_price = team.last_price
    teamPriceMovement = (teamPercentage - averagePercentage)  if teamPriceMovement < 0
    cumulativeDistanceFromAverage += Math.abs(teamPercentage - averagePercentage)
    console.log "team: " + team.name + " got: " + teamPercentage
    console.log "resulting in: " + teamPriceMovement.toFixed(2)
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
                  
  Investment.find(round: round.number).populate("user").populate("team").run (err, investments) ->
    return done err if err
    investments.forEach (investment) ->
      results[investment.team.id] ?=
        team: investment.team, result: 0
      userInvested = investment.percentage * investment.user.getFundsForRoundNbr(round.number)
      results[investment.team.id].result += userInvested
      console.log userInvested
      total += userInvested
      investerList.push investment.user.id unless investerList.indexOf(investment.user.id) >= 0
    
    average = total / teamCount
    averagePercentage = if total > 0 then average / total else 0
    factor = if round.is_first or firstRound.total_funds is 0 then 1 else total / firstRound.total_funds
    console.log results
    console.log "total Invested: " + total
    console.log "number of total teams: " + teamCount
    console.log "average Investment: " + average
    console.log "average As Percentage: " + averagePercentage
    console.log "number of investors: " + investerList.length
    console.log "factor: " + factor

    saveResults results, 0, (err) ->
      return done err if err
      round.standard_deviation = cumulativeDistanceFromAverage / teamCount
      round.total_funds = total
      round.investor_count = investerList.length
      round.average = averagePercentage
      round.factor = factor
      console.log "sd= " + round.standard_deviation
      round.is_open = false
      round.save (err) ->
        return done err if err
        rewardUsersForInvestments investments, 0, (err) ->
          return done err if err
          done()

reset = (done) ->
  options = multi: true
  Transaction.find({}).remove (err) ->
    return done err if err
    Investment.find({}).remove (err) ->
      return done err if err
      Result.find({}).remove (err) ->
        return done err if err
        User.update {},
          $set:
            funds: []
        , options, (err) ->
          return done err if err
          Team.update {},
            $set:
              movement: 0
              last_price: 1.00
              movement_percentage: 0
          , options, (err) ->
            return done err if err
            Round.update {},
              $set:
                is_open: false
                is_current: false
                total_funds: 0
                allocated: 0
                factor: 1
                investor_count: 0
                average: 0
              $unset:
                standard_deviation: 1
            , options, (err) ->
              return done err if err
              Round.findOne(number: 1).update
                $set:
                  is_current: true
              , (err) -> done err
                  
module.exports = 
  rounds: process
  reset: reset
