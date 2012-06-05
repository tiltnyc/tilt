Team = require("../models/team")
AuthHelpers = require("../helpers/auth_helpers")
TeamHelpers = require("../helpers/team_helpers")
SystemHelpers = require("../helpers/system_helpers")
module.exports = (app) ->
  app.get "/teams.:format?", (req, res) ->
    if req.params.format is "json"
      TeamHelpers.getUserInvestable req.user, (err, teams) ->
        return SystemHelpers.error(req, res, err)  if err
        res.contentType "application/json"
        res.send JSON.stringify(teams)
    else
      Team.find({}).asc("name").populate("users").run (err, teams) ->
        return SystemHelpers.error(req, res, err, "/")  if err
        res.render "teams/index",
          title: "List of Teams"
          teams: (if (teams) then teams else [])

  app.get "/teams/new", AuthHelpers.restricted, (req, res) ->
    res.render "teams/new",
      title: "New Team"

  app.post "/teams", AuthHelpers.restricted, (req, res) ->
    team = new Team(req.body.team)
    team.save (err) ->
      req.flash "notice", "Created."
      res.redirect "/team/" + team._id

  app.param "teamId", AuthHelpers.restricted, (req, res, next, id) ->
    Team.findOne(
      _id: id
    , (err, team) ->
      return next(err)  if err
      return next(new Error("Failed loading team " + id))  unless team
      req.team = team
      next()
    ).populate "users"

  app.get "/team/:teamId.:format?", AuthHelpers.restricted, (req, res) ->
    if req.params.format is "json"
      res.contentType "application/json"
      res.send JSON.stringify(req.team)
    else
      res.render "teams/show",
        title: req.team.name
        team: req.team

  app.get "/team/:teamId/edit", AuthHelpers.restricted, (req, res) ->
    res.render "teams/edit",
      title: "Edit " + req.team.name
      team: req.team

  app.put "/teams/:teamId", AuthHelpers.restricted, (req, res) ->
    team = req.team
    team.name = req.body.team.name  if req.body.team.name
    team.save (err, doc) ->
      throw err  if err
      req.flash "notice", "Updated successfully"
      res.redirect "/team/" + team._id

  app.del "/team/:teamId", AuthHelpers.restricted, (req, res) ->
    team = req.team
    team.remove (err) ->
      req.flash "notice", "Deleted"
      res.redirect "/teams"