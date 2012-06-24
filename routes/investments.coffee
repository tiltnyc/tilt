Investment = require("../models/investment")
Team = require("../models/team")
User = require("../models/user")
Round = require("../models/round")
RoundHelpers = require("../helpers/round_helpers")
AuthHelpers = require("../helpers/auth_helpers")
TeamHelpers = require("../helpers/team_helpers")
SystemHelpers = require("../helpers/system_helpers")
Process = require("../processors/investments")

module.exports = (app) ->
  handleError = (req, res, error, redirect) ->
    if req.params.format is "json"
      res.contentType "application/json"
      res.send JSON.stringify(error: error)
    else
      req.flash "error", error
      res.redirect redirect
  app.get "/investment/new", AuthHelpers.loggedIn, RoundHelpers.loadCurrentRound, (req, res) ->
    TeamHelpers.getUserInvestable req.user, (err, teams) ->
      return SystemHelpers.error(req, res, err)  if err
      res.render "investments/new",
        title: "New Investment"
        teams: teams
        currentRound: req.currentRound

  app.post "/investments.:format?", AuthHelpers.loggedIn, RoundHelpers.loadCurrentRound, (req, res) ->
    console.log req.body
    return handleError(req, res, "Not authorized.", "/")  if req.body.investment.user and not req.user.is_admin
    user = req.body.investment.user or req.user
    user = User.findOne(_id: user._id or user).run (err, user) ->
     
      return handleError(req, res, "invalid user", "/investment/new")  if err

      if !req.body.investment.investments
        req.body.investment.investments = []
        for prop of req.body.investment
          req.body.investment.investments[prop.split("_")[1]] = req.body.investment[prop]  if prop.substring(0, 5) is "team_"
      
      return handleError(req, res, "no current round.", "/investment/new") unless req.currentRound
      return handleError(req, res, "cannot invest - round no longer open.", "/investment/new")  unless req.currentRound.is_open
    
      Process.investments user, req.body.investment.investments, req.currentRound, (err, investments) ->
        return handleError(req, res, err, "/investment/new") if err
        if req.params.format is "json"
          res.contentType "application/json"
          res.send JSON.stringify(investments)
        else
          req.flash "notice", "invested successfully."
          if req.user.is_admin
            res.redirect "/investment/new"
          else
            res.redirect "/user/dash"