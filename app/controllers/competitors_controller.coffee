BaseController = require './base_controller'
Competitor = require '../../models/competitor'
CompetitorHelpers = require '../../helpers/competitor_helpers'
User = require '../../models/user'

class CompetitorsController extends BaseController

  setParam: (request, response, next, id) ->
    Competitor.findById(id).populate("user").populate("team").exec (err, competitor) ->
      return next(err) if err
      request.competitor = competitor
      next()

  redirect = (request) ->
    if request.user.is_admin then '/users' else '/competitor/dash'

  index: (request, response) ->
    Competitor.find(event: request.currentEvent.id).populate("user").populate("team").exec (err, competitors) ->
      console.log competitors

      throw err if err
      if request.params.format is 'json'
        response.contentType 'application/json'
        response.send JSON.stringify(competitors)
      else
        response.render 'competitors/index',
          title: 'List of Competitors'
          competitors: competitors

  show: (request, response) ->
    console.log request.currentEvent
    response.render 'competitors/dash',
      title: 'Competitor Dashboard'
      competitor: request.competitor
      currentRound: request.currentRound

  dash: (request, response) ->
    #find if this user
    Competitor.findOne(event: request.currentEvent.id, user: request.user.id).populate("user").populate("team").exec (err, competitor) =>
      if competitor
        request.competitor = competitor
        return @show(request, response)
      response.render 'competitors/dash',
        title: 'Competitor Dashboard'
        event: request.currentEvent
      
  create: (request, response) ->
    uid = if request.user.is_admin and request.body.theUser then request.body.theUser.id else request.user.id
    User.findById(uid).exec (err, user) =>
      console.log err if err
      user.joinAsCompetitor request.currentEvent, (err) =>
        return @error(request, response, "cannot join event.", redirect(request)) if err 
        request.flash 'notice', 'Joined the event.'
        response.redirect redirect(request) 

  edit: (request, response) ->
    response.render 'competitors/edit',
      title: 'Edit Competitor'
      theCompetitor: request.competitor

  update: (request, response) ->
    competitor = request.competitor
    if request.body.competitor.team isnt '' then competitor.addToTeam request.body.competitor.team
    @updateIfChanged ["team"], competitor, request.body.competitor
    competitor.save (error, doc) ->
      throw error if error
      request.flash 'notice', 'Updated successfully'
      response.redirect '/competitors'

  delete: (request, response) ->
    competitor = request.competitor
    competitor.remove (error) ->
      request.flash 'notice', 'competitor Deleted'
      response.redirect '/competitors'

module.exports = CompetitorsController