BaseController = require 'base_controller'
User           = require '../../models/user'
UserHelpers    = require '../../helpers/user_helpers'

class UsersController extends BaseController

  dash: (request, response) ->
    User.findOne(_id: request.user.id).populate('team').run (error, user) ->
      if error
        five_hundred(request, response, error, '/')
      else
        UserHelpers.loadInvestments user, (error, investments) ->
          if error
            five_hundred(request, response, error, '/')
          else
            user.investments = investments
            UserHelpers.loadTransactions user, (error, transactions) ->
              if error
                five_hundred(request, response, error, '/')
              else
                user.transactions = transactions
                response.render 'users/dash',
                  title: 'Dashboard'
                  theUser: user
                  currentRound: request.currentRound

module.exports = UsersController
