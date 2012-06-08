Round = require("../models/round")
User = require("../models/user")
Transaction = require("../models/transaction")
Investment = require("../models/investment")
Team = require("../models/team")
Result = require("../models/result")
RoundHelpers = require("../helpers/round_helpers")
TeamHelpers = require("../helpers/team_helpers")
AuthHelpers = require("../helpers/auth_helpers")
module.exports = (app) ->
  handleError = (req, res, error, redirect) ->
    if req.params.format is "json"
      res.contentType "application/json"
      res.send JSON.stringify(error: error)
    else
      req.flash "error", error
      res.redirect redirect
  redirect = "/rounds"
  app.get "/rounds", AuthHelpers.restricted, TeamHelpers.loadTeamCount, (req, res) ->
    Round.find({}).asc("number").run (err, rounds) ->
      res.render "rounds/index",
        title: "Rounds"
        rounds: rounds
        teamCount: req.teamCount

  app.post redirect, AuthHelpers.restricted, (req, res) ->
    Round.count {}, (err, numRounds) ->
      return err  if err
      isCurrentRound = (numRounds is 0)
      round = new Round(
        number: numRounds + 1
        is_current: isCurrentRound
      )
      round.save (err, round) ->
        return err  if err
        req.flash "notice", "Round appended."
        res.redirect redirect

  app.param "roundNumber", AuthHelpers.restricted, (req, res, next, number) ->
    Round.findOne(number: number).run (err, round) ->
      return next(err)  if err
      return next(new Error("Failed loading round " + number))  unless round
      req.round = round
      next()

  app.del "/round/:roundNumber", AuthHelpers.restricted, (req, res) ->
    round = req.round
    round.remove (err) ->
      req.flash "notice", "Removed round"
      res.redirect redirect

  app.get "/rounds/current.:format?", AuthHelpers.restricted, (req, res) ->
    Round.findOne(is_current: true).run (err, round) ->
      if req.params.format is "json"
        res.contentType "application/json"
        res.send JSON.stringify(round)
      else
        res.render "rounds/current",
          title: "Current Round"
          round: round

  app.put "/round/:roundNumber", AuthHelpers.restricted, (req, res) ->
    round = req.round
    round.is_open = (req.body.round.is_open.toLowerCase() is "true")  if req.body.round.is_open
    if req.body.round.next_round
      round.is_current = false
      round.is_open = false
    round.save (err) ->
      return handleError(req, res, err, redirect)  if err
      if req.body.round.next_round
        Round.findOne(number: req.round.number + 1).run (err, round) ->
          return handleError(req, res, err, redirect)  if err
          return handleError(req, res, "no round found.", redirect)  unless round
          round.is_current = true
          round.save (err) ->
            return handleError(req, res, err, redirect)  if err
            req.flash "notice", "Round progressed."
            res.redirect redirect
      else
        req.flash "notice", "Round toggled."
        res.redirect redirect

  app.put "/round/:roundNumber/process", AuthHelpers.restricted, TeamHelpers.loadTeamCount, RoundHelpers.loadFirstRound, (req, res) ->
    round = req.round
    results = {}
    total = 0
    investerList = []
    return handleError(req, res, "cannot process again.", redirect)  if round.processed
    Investment.find(round: round.number).populate("user").populate("team").run (err, investments) ->
      saveResults = (data, index, callback) ->
        if Object.keys(data).length is index
          return callback()
        else
          teamId = Object.keys(data)[index]
          team = data[teamId].team
          teamPercentage = data[teamId].result / total
          teamPriceMovement = ((teamPercentage - averagePercentage) * factor)
          before_price = team.last_price
          teamPriceMovement = (teamPercentage - averagePercentage)  if teamPriceMovement < 0
          cumulativeDistanceFromAverage += Math.abs(teamPercentage - averagePercentage)
          console.log "team: " + team.name + " got: " + teamPercentage
          console.log "resulting in: " + teamPriceMovement.toFixed(2)
          team.last_price += teamPriceMovement
          team.movement = teamPriceMovement
          team.movement_percentage = teamPriceMovement / before_price
          team.save (err, team) ->
            return callback(err)  if err
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
            fundsInRound = undefined
            investedInTeam = investment.percentage * (if isNaN(fundsInRound = investment.user.getFundsForRoundNbr(round.number)) then 0 else fundsInRound)
            investmentReturnForTeam = investedInTeam * results[investment.team.id].team.last_price
            new Transaction(
              user: investment.user.id
              round: round.number + 1
              label: "return for round " + round.number + " investment in team: " + investment.team.name
              amount: investmentReturnForTeam
            ).save (err) ->
              return callback(err)  if err
              rewardUsersForInvestments investments, index + 1, callback
          else
            rewardUsersForInvestments investments, index + 1, callback
        else
          callback()
      investments.forEach (investment) ->
        unless results[investment.team.id]
          results[investment.team.id] =
            team: investment.team
            result: 0
        userInvested = investment.percentage * investment.user.getFundsForRoundNbr(round.number)
        results[investment.team.id].result += userInvested
        total += userInvested
        investerList.push investment.user.id  if investerList.indexOf(investment.user.id) < 0

      average = total / req.teamCount
      averagePercentage = average / total
      cumulativeDistanceFromAverage = 0
      factor = if round.is_first then 1 else total / req.firstRound.total_funds
      console.log results
      console.log "total Invested: " + total
      console.log "number of total teams: " + req.teamCount
      console.log "average Investment: " + average
      console.log "average As Percentage: " + averagePercentage
      console.log "number of investors: " + investerList.length
      console.log "factor: " + factor
      saveResults results, 0, (err) ->
        return handleError(req, res, err, redirect)  if err
        round.standard_deviation = cumulativeDistanceFromAverage / req.teamCount
        round.total_funds = total
        round.investor_count = investerList.length
        round.average = averagePercentage
        round.factor = factor
        console.log "sd= " + round.standard_deviation
        round.is_open = false
        round.save (err) ->
          rewardUsersForInvestments investments, 0, (err) ->
            return handleError(req, res, err, redirect)  if err
            req.flash "notice", "Round " + round.number.toString() + " processed."
            res.redirect redirect

  app.post "/round/:roundNumber/allocate", AuthHelpers.restricted, (req, res) ->
    stream = User.find().stream()
    round = req.round
    amount = new Number(req.body.allocate.amount)
    number = round.number
    stream.on "data", (user) ->
      @pause()
      self = this
      new Transaction(
        amount: amount
        round: number
        user: user.id
        label: "round " + number.toString() + " allocation."
      ).save (err, doc) ->
        return handleError(req, res, err, redirect)  if err
        self.resume()

    errorMode = false
    stream.on "error", (err) ->
      req.flash "error", "Error allocating funds."
      res.redirect redirect
      @destroy()

    stream.on "close", ->
      round.allocated += amount
      round.save (err) ->
        if err
          handleError req, res, err, redirect
        else
          req.flash "notice", "Allocated funds to all users for round " + req.round.number.toString() + "."
          res.redirect redirect

  app.post "/rounds/reset", AuthHelpers.restricted, (req, res) ->
    options = multi: true
    Transaction.find({}).remove (err) ->
      Investment.find({}).remove (err) ->
        Result.find({}).remove (err) ->
          User.update {},
            $set:
              funds: []
          , options, (err) ->
            return handleError(req, res, err, redirect)  if err
            Team.update {},
              $set:
                movement: 0
                last_price: 1.00
                movement_percentage: 0
            , options, (err) ->
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
                Round.findOne(number: 1).update
                  $set:
                    is_current: true
                , (err) ->
                  req.flash "notice", "tilt has been reset."
                  res.redirect redirect