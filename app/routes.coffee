Allocation        = require '../processors/allocation'
AuthHelpers       = require '../helpers/auth_helpers'
Investment        = require '../models/investment'
EventsController  = require '../app/controllers/events_controller'
TeamsController   = require '../app/controllers/teams_controller'
RoundsController  = require '../app/controllers/rounds_controller'
ResultsController = require '../app/controllers/results_controller'
InvestmentsController = require '../app/controllers/investments_controller'
CompetitorsController = require '../app/controllers/competitors_controller'
HomeController    = require '../app/controllers/home_controller'
Process           = require '../processors/investments'
Result            = require '../models/result'
Round             = require '../models/round'
RoundHelpers      = require '../helpers/round_helpers'
EventHelpers      = require '../helpers/event_helpers'
SystemHelpers     = require '../helpers/system_helpers'
CompetitorHelper  = require '../helpers/competitor_helpers'
TeamHelpers       = require '../helpers/team_helpers'
Transaction       = require '../models/transaction'
UsersController   = require '../app/controllers/users_controller'
UserHelpers       = require '../helpers/user_helpers'


module.exports = (app) ->

  redirect = '/rounds'

  handleError = (req, res, error, redirect) ->
    if req.params.format is 'json'
      res.contentType 'application/json'
      res.send JSON.stringify(error: error)
    else
      req.flash 'error', error
      res.redirect redirect

  map = (Controller, route) ->
    action = route.action ? route.path.match(/[a-zA-Z0-9\-_]+(?=\/$|$)/)[0]
    middleware = if route.middleware instanceof Array then route.middleware else if route.middleware then [route.middleware] else []
    middleware.splice(0, 0, EventHelpers.loadCurrentEvent, CompetitorHelper.loadCompetitor)
    args = [route.path].concat middleware, (request, response, next, id) ->
      new Controller()[action](request, response, next, id)
    app[route.method ? 'get'].apply app, args

  mapToController = (Controller, routes) -> map Controller, route for route in routes

  mapToController EventsController,
  [
    path: 'event_id'
    method: 'param'
    action: 'setParam'
  ,
    path: '/events/new'
    middleware: AuthHelpers.restricted
  ,
    path: '/events.:format?'
    action: 'index'
  ,
    path: '/events'
    method: 'post'
    action: 'create'
    middleware: AuthHelpers.restricted
  ,
    path: '/event/:event_id.:format?'
    action: 'show'
  ,
    path: '/event/:event_id/edit'
    middleware: AuthHelpers.restricted
  ,
    path: '/events/:event_id'
    method: 'put'
    action: 'update'
    middleware: AuthHelpers.restricted
  ,
    path: '/event/:event_id'
    method: 'del'
    action: 'delete'
    middleware: AuthHelpers.restricted
  ]   


  mapToController UsersController,
  [
    path: '/user/profile'
    middleware: [AuthHelpers.loggedIn, RoundHelpers.loadCurrentRound]
  ,
    path: 'id'
    method: 'param'
    action: 'setParam'
  ,
    path: '/users/new'
    middleware: AuthHelpers.restricted
  ,
    path: '/users.:format?'
    action: 'index'
    middleware: AuthHelpers.restricted
  ,
    path: '/users'
    method: 'post'
    action: 'create'
    middleware: AuthHelpers.restricted
  ,
    path: '/user/:id.:format?'
    action: 'show'
  ,
    path: '/user/:id/edit'
    middleware: AuthHelpers.restricted
  ,
    path: '/users/:id'
    method: 'put'
    action: 'update'
    middleware: AuthHelpers.restricted
  ,
    path: '/user/:id'
    method: 'del'
    action: 'delete'
    middleware: AuthHelpers.restricted
  ]   

  mapToController TeamsController,
  [
    path: 'team_id'
    method: 'param'
    action: 'setParam'
  ,
    path: '/teams/new'
    middleware: AuthHelpers.restricted
  ,
    path: '/teams.:format?'
    action: 'index'
  ,
    path: '/teams'
    method: 'post'
    action: 'create'
    middleware: AuthHelpers.restricted
  ,
    path: '/team/:team_id.:format?'
    action: 'show'
  ,
    path: '/team/:team_id/edit'
    middleware: AuthHelpers.restricted
  ,
    path: '/teams/:team_id'
    method: 'put'
    action: 'update'
    middleware: AuthHelpers.restricted
  ,
    path: '/team/:team_id'
    method: 'del'
    action: 'delete'
    middleware: AuthHelpers.restricted
  ]   

  mapToController RoundsController,
  [
    path: 'round_nbr'
    method: 'param'
    action: 'setParam'
  ,  
    path: '/rounds'
    action: 'index'
    middleware: [AuthHelpers.restricted, TeamHelpers.loadTeamCount] 
  ,
    path: '/rounds'
    method: 'post'
    action: 'append'
    middleware: AuthHelpers.restricted 
  ,
    path: '/round/:round_nbr'
    method: 'del'
    action: 'delete'
    middleware: AuthHelpers.restricted
  ,
    path: '/rounds/current.:format?'
    action: 'current'
    middleware: AuthHelpers.restricted
  ,
    path: '/round/:round_nbr'
    action: 'update'
    method: 'put'
    middleware: AuthHelpers.restricted
  ,
    path: '/round/:round_nbr/process'
    method: 'put'
    middleware: AuthHelpers.restricted 
  ,
    path: '/round/:round_nbr/allocate'
    method: 'post'
    middleware: AuthHelpers.restricted
  ,
    path: '/rounds/reset'
    method: 'post'
    middleware: AuthHelpers.restricted
  ]

  mapToController CompetitorsController, 
  [
    path: '/competitors.:format?'
    action: 'index'
  ,
    path: '/competitor/dash'
    middleware: [AuthHelpers.loggedIn, RoundHelpers.loadCurrentRound]
  ,
    path: 'comp_id'
    method: 'param'
    action: 'setParam'
  ,
    path: '/competitor/:comp_id/show'
    middleware: [AuthHelpers.loggedIn, RoundHelpers.loadCurrentRound]
  ,
    path: '/competitor/create'
    middleware: [AuthHelpers.loggedIn]
    method: 'post'
  ]

  mapToController ResultsController,
  [
    path: '/results.:format?'
    action: 'index'
    middleware: RoundHelpers.loadCurrentRound
  ]

  mapToController InvestmentsController, 
  [
    path: '/investment/new'
    middleware: [AuthHelpers.loggedIn, RoundHelpers.loadCurrentRound, CompetitorHelper.isCompetitor] 
  ,
    path: '/investments.:format?'
    middleware: [AuthHelpers.loggedIn, RoundHelpers.loadCurrentRound] 
    method: 'post'  
    action: 'create'
  ]

  mapToController HomeController,
  [
    path: '/'
    action: 'index'
  ,
    path: '/login.json'
    action: 'login'
  ]