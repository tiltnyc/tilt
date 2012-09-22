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
    User.find().exclude(['hash','salt']).asc('username').exec (error, users) ->
      throw error if error

      populateRoles = (i, done) ->
        return done() if i >= users.length
        user = users[i]
        user.populateCompetingIn () ->
          user.populateInvestingIn () -> populateRoles i+1, done

      populateRoles 0, () ->   
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
    request.theUser.populateCompetingIn () ->
      request.theUser.populateInvestingIn () ->
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
    user = if request.theUser then request.theUser else request.user

    Competitor.find(user: user.id).populate('user').populate('event').populate('team').exec (err, competitors) ->
      throw error if err
      response.render 'users/profile',
        title: 'Profile'
        theUser: user
        competitors: competitors
        currentRound: request.currentRound
module.exports = UsersController
