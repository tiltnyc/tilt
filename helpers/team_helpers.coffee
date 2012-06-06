Team = require("../models/team")
exports.loadTeamCount = (req, res, next) ->
  Team.count {}, (err, count) ->
    return next(err)  if err
    req.teamCount = count
    next()

exports.getUserInvestable = (user, next) ->
  query = {}
  if user and not user.is_admin and user.team
    query = _id:
      $ne: user.team
  Team.find(query).asc("name").run (err, teams) ->
    return next(err)  if err
    next null, (if (teams) then teams else [])