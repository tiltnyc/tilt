BaseController = require './base_controller'
User           = require '../../models/user'
UserHelpers    = require '../../helpers/user_helpers'

class UsersController extends BaseController

  dash: (request, response) ->
    User.findOne(_id: request.user.id).populate('team').run (error, user) ->
      throw error if error
      UserHelpers.loadInvestments user, (error, investments) ->
        throw error if error
        user.investments = investments
        UserHelpers.loadTransactions user, (error, transactions) ->
          throw error if error
          user.transactions = transactions
          response.render 'users/dash',
            title: 'Dashboard'
            theUser: user
            currentRound: request.currentRound

module.exports = UsersController
