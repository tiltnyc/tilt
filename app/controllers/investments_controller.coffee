BaseController  = require './base_controller'
Investment      = require '../../models/investment'
User            = require '../../models/user'
Investor      = require '../../models/investor'
Process         = require '../../processors/investments'
TeamHelpers     = require '../../helpers/team_helpers'

class InvestmentController extends BaseController

  new: (request, response) ->
    TeamHelpers.getTeamsExceptUsers request.currentEvent, request.user, (err, teams) =>
      return @error(request, response, err, '/') if err
      response.render 'investments/new',
        title: 'New Investment'
        teams: teams
        currentRound: request.currentRound

  create: (request, response) ->
    error = (msg) => @error(request, response, msg, '/investment/new') 

    return error 'Not authorized' if request.body.investment.investor and not request.user.is_admin
    return error "Admin isn't setup to invest"  if request.user.is_admin and not request.body.investment.investor and not request.currentInvestor

    iid = if request.user.is_admin and request.body.investment.investor then request.body.investment.investor else request.currentInvestor.id

    Investor.findById(iid).exec (err, investor) =>
      return error err if err
      return "cannot invest - not setup as investors" if !investor

      if !request.body.investment.investments
        request.body.investment.investments = []
        for prop of request.body.investment
          request.body.investment.investments[prop.split('_')[1]] = request.body.investment[prop]  if prop.substring(0, 5) is 'team_'

      return error 'cannot invest - no currently open round' unless request.currentRound
      return error 'cannot invest - round no longer open' unless request.currentRound.is_open

      Process.investments investor, request.body.investment.investments, request.currentRound, (err, investments) ->
        return error err if err
        if request.params.format is 'json'
          response.contentType 'application/json'
          response.send JSON.stringify(investments)
        else
          request.flash 'notice', 'invested successfully.'
          if request.user.is_admin
            response.redirect '/investment/new'
          else
            response.redirect '/investor/dash'


module.exports = InvestmentController