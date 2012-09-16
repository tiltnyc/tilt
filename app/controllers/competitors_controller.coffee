BaseController = require './base_controller'
Competitor = require '../../models/Competitor'

class CompetitorsController extends BaseController
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



module.exports = CompetitorsController