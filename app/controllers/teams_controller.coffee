BaseController  = require './base_controller'
Team            = require '../../models/team'
User            = require '../../models/user'
TeamHelpers     = require '../../helpers/team_helpers'
UserHelpers     = require '../../helpers/user_helpers'

class TeamsController extends BaseController

  setParam: (request, response, next, id) ->
    Team.findById(id).populate('competitors').exec (err, team) ->
      UserHelpers.populate team.competitors, () ->
        return next(err)  if err
        return next(new Error('Failed loading team ' + id)) unless team
        request.team = team
        next()

  index: (request, response) ->
    if request.params.format is 'json'
      TeamHelpers.getUserInvestable request.currentEvent, request.user, (err, teams) ->
        throw err if err
        response.contentType 'application/json'
        response.send JSON.stringify(teams)
    else
      Team.find(event: request.currentEvent.id).sort("name", "ascending").populate('competitors').exec (err, teams) ->
        throw err if err
        response.render 'teams/index',
          title: 'List of Teams'
          teams: (if (teams) then teams else [])

  new: (request, response) ->
    response.render 'teams/new',
      title: 'New Team'

  create: (request, response) ->
    team = new Team(request.body.team)
    team.save (err) ->
      throw err if err
      request.flash 'notice', 'Created.'
      response.redirect '/team/' + team._id

  show: (request, response) ->
    if request.params.format is 'json'
      response.contentType 'application/json'
      response.send JSON.stringify(request.team)
    else
      response.render 'teams/show',
        title: request.team.name
        team: request.team

  edit: (request, response) ->
    response.render 'teams/edit',
      title: 'Edit ' + request.team.name
      team: request.team

  update: (request, response) ->
    team = request.team
    return @error(request, response, 'cannot modify', '/') unless request.user.is_admin or (request.currentCompetitor and request.currentCompetitor.team is team.id)
    
    console.log request.files

    @updateIfChanged ["name"], team, request.body.team
    team.save (err, team) ->
      throw err if err
      request.flash 'notice', 'Updated successfully'
      response.redirect '/team/' + team._id

  delete: (request, response) ->
    team = request.team
    team.remove (err) ->
      request.flash 'notice', 'Deleted'
      response.redirect '/teams'

module.exports = TeamsController
