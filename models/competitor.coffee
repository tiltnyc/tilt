{mongoose, Schema, ObjectId} = require("./db_connect")

mongooseAuth = require("mongoose-auth")

CompetitorSchema = new Schema(
  user:
    type: ObjectId
    ref: "User"
    required: true

  event:
    type: ObjectId 
    ref:  "Event"
    required: true
  
  team:
    type: ObjectId
    ref: "Team"

  funds:
    type: [ Number ]
    default: []

  created_at:
    type: Date
    default: Date.now

  updated_at:
    type: Date
    default: Date.now
)


CompetitorSchema.methods.getFundsForRoundNbr = (roundNbr) ->
  @funds[roundNbr - 1] ? 0

CompetitorSchema.methods.addFundsForRoundNbr = (roundNbr, funds) ->
  i = roundNbr - 1
  _funds = @funds.concat()
  x = 0
  _funds[x++] ?= 0 while x < roundNbr #ensure funds for previous rounds initialised
  _funds[i] += funds
  @funds = _funds

CompetitorSchema.methods.addToTeam = (team) ->
  @oldTeam = @team
  @team = team

Team = require("./team")
CompetitorSchema.pre "save", (next) ->
  leaveTeam = (competitor, callback) ->
    return callback() unless competitor.oldTeam
    Team.findById competitor.oldTeam, (err, team) ->
      return callback(err)  if err
      team.competitors.splice team.competitors.indexOf(competitor._id), 1
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

exports = module.exports = mongoose.model("Competitor", Competitor)
