BaseController = require './base_controller'
Investor = require '../../models/Investor'
InvestorHelpers = require '../../helpers/investor_helpers'
User = require '../../models/User'

class InvestorsController extends BaseController

  setParam: (request, response, next, id) ->
    Investor.findById(id).populate("user").populate("team").exec (err, investor) ->
      return next(err) if err
      request.investor = investor
      next()

  redirect = (request) ->
    if request.user.is_admin then '/users' else '/investor/dash'

  index: (request, response) ->
    Investor.find(event: request.currentEvent.id).populate("user").populate("team").exec (err, investors) ->
      throw err if err

      if request.params.format is 'json'
        response.contentType 'application/json'
        response.send JSON.stringify(investors)
      else
        response.render 'investors/index',
          title: 'List of Investors'
          investors: investors

  show: (request, response) ->
    InvestorHelpers.loadInvestments request.currentEvent, request.investor, (error, investments) ->
      throw error if error
      request.investor.investments = investments
      InvestorHelpers.loadTransactions request.currentEvent, request.investor, (error, transactions) ->
        throw error if error
        request.investor.transactions = transactions
        response.render 'investors/dash',
          title: 'Investor Dashboard'
          investor: request.investor
          currentRound: request.currentRound
          event: request.currentEvent

  dash: (request, response) ->
    #find if this user
    Investor.findOne(event: request.currentEvent.id, user: request.user.id).populate("user").populate("team").exec (err, investor) =>
      if investor
        request.investor = investor
        return @show(request, response)
      response.render 'investors/dash',
        title: 'Investor Dashboard'
        event: request.currentEvent
      
  create: (request, response) ->
    uid = if request.user.is_admin and request.body.theUser then request.body.theUser.id else request.user.id
    User.findById(uid).exec (err, user) =>
      user.joinAsInvestor request.currentEvent, (err) =>
        return @error(request, response, "cannot join event.", redirect(request)) if err 
        request.flash 'notice', 'Joined the event.'
        response.redirect redirect(request) 

module.exports = InvestorsController