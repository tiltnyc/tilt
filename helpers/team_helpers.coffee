Team = require("../models/team")

exports.loadTeamCount = (req, res, next) ->
  Team.count {event: req.currentEvent._id}, (err, count) ->
    return if err
    req.teamCount = count
    next()

exports.getTeamsExceptUsers = (event, user, competitor, next) ->
  query = 
    event: event._id
  if user and not user.is_admin and competitor and competitor.team
    query._id =
      $ne: competitor.team
  Team.find(query).asc("name").run (err, teams) ->
    return next(err)  if err
    next null, (if (teams) then teams else [])