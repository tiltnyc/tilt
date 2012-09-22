BaseController = require './base_controller'
User           = require '../../models/user'
Transaction    = require '../../models/transaction'
Investment     = require '../../models/investment'
Competitor     = require '../../models/competitor'


class UsersController extends BaseController

  setParam: (request, response, next, id) ->
    User.findById(id).exec (err, user) ->
      return next(err) if err
      return next(new Error('Failed loading user ' + id)) unless user
      request.theUser = user
      next()

  index: (request, response) ->
    User.find().populate('competing_in').asc('username').exec (error, users) ->
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
    user = new User(request.body.user)
    user.save (error) ->
      throw error if error
      request.flash 'notice', 'Created.'
      response.redirect '/user/' + user._id

  show: (request, response) ->
    Transaction.find(user: request.theUser.id).asc('round', 'created').exec (error, transactions) ->
      throw error if error
      request.theUser.transactions = transactions
      Investment.find(user: request.theUser.id).populate('team').asc('round', 'team.name').exec (error, investments) ->
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
    @updateIfChanged ["username", "email"], user, request.body.user
    user.save (error, doc) ->
      throw error if error
      request.flash 'notice', 'Updated successfully'
      response.redirect '/user/' + user._id

  delete: (request, response) ->
    user = request.theUser
    user.remove (error) ->
      request.flash 'notice', 'Deleted'
      response.redirect '/users'

  profile: (request, response) ->
    Competitor.find(user: request.user.id).populate('user').populate('event').populate('team').exec (err, competitors) ->
      throw error if err
      response.render 'users/profile',
        title: 'Profile'
        theUser: request.user
        competitors: competitors
        currentRound: request.currentRound
module.exports = UsersController
