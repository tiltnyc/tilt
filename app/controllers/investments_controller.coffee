BaseController  = require './base_controller'
Investment      = require '../../models/investment'
User            = require '../../models/user'
Process         = require '../../processors/investments'
TeamHelpers     = require '../../helpers/team_helpers'

class InvestmentController extends BaseController

  new: (request, response) ->
    TeamHelpers.getUserInvestable request.user, (err, teams) ->
      throw err if err
      response.render 'investments/new',
        title: 'New Investment'
        teams: teams
        currentRound: request.currentRound

  create: (request, response) ->
    console.log request.body
    return throw 'Not authorized' if request.body.investment.user and not request.user.is_admin
    
    user = request.body.investment.user or request.user
    user = User.findById(user._id or user).exec (err, user) ->

      # return handleError(req, res, 'invalid user', '/investment/new')  if err
      throw err if err

      if !request.body.investment.investments
        request.body.investment.investments = []
        for prop of request.body.investment
          request.body.investment.investments[prop.split('_')[1]] = request.body.investment[prop]  if prop.substring(0, 5) is 'team_'

      throw 'no current round.' unless request.currentRound
      throw 'cannot invest - round no longer open.' unless request.currentRound.is_open

      Process.investments user, request.body.investment.investments, request.currentRound, (err, investments) ->
        throw err if err
        if request.params.format is 'json'
          response.contentType 'application/json'
          response.send JSON.stringify(investments)
        else
          request.flash 'notice', 'invested successfully.'
          if request.user.is_admin
            response.redirect '/investment/new'
          else
            response.redirect '/user/dash'


module.exports = InvestmentController