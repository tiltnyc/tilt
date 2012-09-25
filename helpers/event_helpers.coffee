Event = require "../models/event"
Team = require "../models/team"

exports.loadCurrentEvent = (req, res, next) ->
  setCurrentEvent = (evt) ->
    evt.id = evt._id if !evt.id
    req.currentEvent = evt
    res.local('currentEvent', evt)
    next()

  return setCurrentEvent(req.session.currentEvent) if req.session.currentEvent

  Event.find({date:{$gte: new Date(new Date().setHours(0,0,0,0))}}).sort("date","ascending").limit(1).exec (err, events) ->
    throw err if err
    setCurrentEvent(events[0])

exports.populateTeams = (events, next) ->

  populate = (i, done) ->
    return done() if i >= events.length
    evt = events[i]
    Team.find(event: evt.id).sort('last_price','descending').exec (err, teams) ->
      throw err if err
      evt.teams = teams
      populate i+1, done

  populate 0, () -> next()