BaseController = require './base_controller'
User           = require '../../models/user'
UserHelpers    = require '../../helpers/user_helpers'
Transaction    = require '../../models/transaction'
Investment     = require '../../models/investment'

class UsersController extends BaseController

  index: (request, response) ->
    User.find({}).populate('team').asc('username').run (error, users) ->
      throw error if error

      if request.params.format is 'json'
        response.contentType 'application/json'
        response.send JSON.stringify(users)
      else
        response.render 'users/index',
          title: 'List of Users'
          users: users

  new: (request, response) ->
    response.render 'users/new',
      title: 'New User'

  create: (request, response) ->
    request.body.user.team = null if request.body.user.team is ''
    user = new User(request.body.user)
    user.save (error) ->
      throw error if error
      request.flash 'notice', 'Created.'
      response.redirect '/user/' + user._id

  show: (request, response) ->
    Transaction.find(user: request.theUser._id).asc('round', 'created').run (error, transactions) ->
      throw error if error
      console.log transactions
      console.log request.theUser
      request.theUser.transactions = transactions
      Investment.find(user: request.theUser._id).populate('team').asc('round', 'team.name').run (error, investments) ->
        throw error if error
        request.theUser.investments = investments
        if request.params.format is 'json'
          response.contentType 'application/json'
          response.send JSON.stringify(request.theUser)
        else
          response.render 'users/show',
            title: request.theUser.username
            theUser: request.theUser

  edit: (request, response) ->
    response.render 'users/edit',
      title: 'Edit ' + request.theUser.username
      theUser: request.theUser

  update: (request, response) ->
    user = request.theUser
    user.username = request.body.user.username if request.body.user.username
    user.email = request.body.user.email if request.body.user.email

    if request.body.user.team isnt '' then user.addToTeam request.body.user.team

    user.save (error, doc) ->
      throw error if error
      request.flash 'notice', 'Updated successfully'
      response.redirect '/user/' + user._id

  delete: (request, response) ->
    user = request.theUser
    user.remove (error) ->
      request.flash 'notice', 'Deleted'
      response.redirect '/users'

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
