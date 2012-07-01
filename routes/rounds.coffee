Round = require "../models/round"
User = require "../models/user"
Transaction = require "../models/transaction"
Investment = require "../models/investment"
Team = require "../models/team"
Result = require "../models/result"
RoundHelpers = require "../helpers/round_helpers"
TeamHelpers = require "../helpers/team_helpers"
AuthHelpers = require "../helpers/auth_helpers"
Rounds = require "../processors/rounds"
Allocation = require "../processors/allocation"
Reset = require "../processors/reset"

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
      return handleError(req, res, err, redirect)  if err
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

  #edit the round - toggle open/close or move to the next round
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
    return handleError(req, res, "cannot process again.", redirect) if req.round.processed
    Rounds.process req.round, req.firstRound, req.teamCount, (err) ->
      return handleError(req, res, err, redirect) if err 
      req.flash "notice", "Round " + req.round.number.toString() + " processed."
      res.redirect redirect
    
  app.post "/round/:roundNumber/allocate", AuthHelpers.restricted, (req, res) ->
    Allocation.process req.round, new Number(req.body.allocate.amount), (err) ->
      return handleError(req, res, err, redirect) if err
      req.flash "notice", "Allocated funds to all users for round " + req.round.number.toString() + "."
      res.redirect redirect

  app.post "/rounds/reset", AuthHelpers.restricted, (req, res) ->
    Reset.process (err) ->
      return handleError req, res, err, redirect if err
      req.flash "notice", "tilt has been reset."
      res.redirect redirect