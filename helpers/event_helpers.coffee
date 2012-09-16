Event = require "../models/event"
exports.loadCurrentEvent = (req, res, next) ->
  Event.find({date:{$gte: new Date(new Date().setHours(0,0,0,0))}}).sort("date","ascending").limit(1).exec (err, events) ->
    throw err if err
    req.currentEvent = events[0]
    res.local('currentEvent', events[0])
    next()