BaseController = require './base_controller'
User           = require '../../models/user'
Transaction    = require '../../models/transaction'
Investment     = require '../../models/investment'
Investor       = require '../../models/investor'
Competitor     = require '../../models/competitor'
UploadHelpers  = require '../../helpers/upload_helpers'

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

  roles: (request, response) ->
    response.contentType 'application/json'
    response.send JSON.stringify [
      label:'designer'
    ,  
      label:'engineer'
    ,  
      label:'investor'
    ,
      label:'marketer'
    ,  
      label:'strategy'
    ,
      label:'other'
    ]

  edit: (request, response) ->
    return @error(request, response, 'Unauthorized.', '/') unless request.user.is_admin or request.theUser.id is request.user.id

    response.render 'users/edit',
      title: 'Edit ' + request.theUser.username
      theUser: request.theUser

  update: (request, response) ->
    return @error(request, response, 'Unauthorized.', '/') unless request.user.is_admin or request.theUser.id is request.user.id

    user = request.theUser
    URIs = UploadHelpers.getImageURIs request 
    user.picture = URIs[0] if URIs.length
    @updateIfChanged ["username", "email", "fname", "lname", "company", "bio", "role", "twitter"], user, request.body.user
    user.save (error, doc) ->
      throw error if error
      request.flash 'notice', 'Updated successfully'
      response.redirect if request.user.is_admin then "/user/#{user._id}" else "/user/profile"

  delete: (request, response) ->
    user = request.theUser
    user.remove (error) ->
      request.flash 'notice', 'Deleted'
      response.redirect '/users'

  profile: (request, response) ->
    user = if request.theUser then request.theUser else request.user

    Competitor.find(user: user.id).populate('user').populate('event').populate('team').exec (err, competitors) ->
      Investor.find(user: user.id).populate('user').populate('event').exec (err, investors) ->
        response.render 'users/profile',
          title: user.username
          theUser: user
          competitors: competitors
          investors: investors
          currentRound: request.currentRound
module.exports = UsersController
