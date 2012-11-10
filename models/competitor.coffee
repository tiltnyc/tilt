addTimestamps = require '../lib/timestamps'
Team          = require './team'

{ mongoose, Schema, ObjectId } = require('./db_connect')

Competitor = new Schema
  user:
    type: ObjectId
    ref: 'User'
    required: true

  event:
    type: ObjectId
    ref:  'Event'
    required: true

  team:
    type: ObjectId
    ref: 'Team'

Competitor = addTimestamps(Competitor)

Competitor.methods.addToTeam = (team) ->
  @oldTeam = @team
  @team = team

Competitor.pre 'save', (next) ->
  leaveTeam = (competitor, callback) ->
    return callback() unless competitor.oldTeam
    Team.findById competitor.oldTeam, (err, team) ->
      return callback(err)  if err
      team.competitors.splice team.competitors.indexOf(competitor.id), 1
      team.save (err) ->
        competitor.oldTeam = null
        callback(err ? null)

  joinTeam = (competitor, callback) ->
    return callback() unless competitor.team
    Team.findById competitor.team, (err, team) ->
      return callback(err)  if err
      callback() if !team or team.competitors.indexOf(competitor.id) >= 0
      team.competitors.push competitor._id
      team.save (err) -> callback(err ? null)

  competitor = @

  leaveTeam competitor, (err) ->
    if err then next err
    else joinTeam competitor, (err) -> next(err ? null)

exports = module.exports = mongoose.model('Competitor', Competitor)
