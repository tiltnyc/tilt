BaseController = require './base_controller'
Competitor = require '../../models/Competitor'
CompetitorHelpers = require '../../helpers/competitor_helpers'

class CompetitorsController extends BaseController

  setParam: (request, response, next, id) ->
    Competitor.findById(id).populate("user").populate("team").exec (err, competitor) ->
      return next(err) if err
      request.competitor = competitor
      next()

  index: (request, response) ->
    Competitor.find(event: request.currentEvent.id).populate("user").populate("team").exec (err, competitors) ->
      throw err if err

      if request.params.format is 'json'
        response.contentType 'application/json'
        response.send JSON.stringify(competitors)
      else
        response.render 'competitors/index',
          title: 'List of Competitors'
          competitors: competitors

  show: (request, response) ->
    CompetitorHelpers.loadInvestments request.currentEvent, request.competitor, (error, investments) ->
      throw error if error
      request.competitor.investments = investments
      CompetitorHelpers.loadTransactions request.currentEvent, request.competitor, (error, transactions) ->
        throw error if error
        request.competitor.transactions = transactions
        response.render 'competitors/dash',
          title: 'Competitor Dashboard'
          competitor: request.competitor
          currentRound: request.currentRound
          event: request.currentEvent

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
    new Competitor
      user: request.user.id
      event: request.currentEvent.id
    .save (error) ->
      throw error if error
      request.flash 'notice', 'Joined the event.'
      response.redirect '/competitor/dash'

module.exports = CompetitorsController