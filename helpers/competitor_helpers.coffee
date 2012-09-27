Competitor = require("../models/competitor")

exports.isCompetitor = (req, res, next) ->
  result = () ->
    req.flash "error", new Error("Not competing in event.")
    res.redirect "/"

  return result() unless req.user
  Competitor.findOne(event: req.currentEvent.id, user: req.user.id).exec (err, competitor) ->
    return next(err) if err
    return result() unless competitor or req.user.is_admin
    next()

exports.loadCompetitor = (req, res, next) ->
  return next() unless req.user and req.currentEvent
  Competitor.findOne(event: req.currentEvent.id, user: req.user.id).populate("team").exec (err, competitor) ->
    return next(err) if err
    if competitor
      req.currentCompetitor = competitor 
      res.local('currentCompetitor', competitor)
    next()