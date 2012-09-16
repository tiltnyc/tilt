Event = require "../models/event"
exports.loadCurrentEvent = (req, res, next) ->
  Event.find({date:{$gte: new Date(new Date().setHours(0,0,0,0))}}).sort("date","ascending").limit(1).exec (err, event) ->
    throw err if err
    req.currentEvent = event
    next()