Allocation      = require '../processors/allocation'
AuthHelpers     = require '../helpers/auth_helpers'
Investment      = require '../models/investment'
Process         = require '../processors/investments'
Reset           = require '../processors/reset'
Result          = require '../models/result'
Round           = require '../models/round'
RoundHelpers    = require '../helpers/round_helpers'
Rounds          = require '../processors/rounds'
SystemHelpers   = require '../helpers/system_helpers'
Team            = require '../models/team'
TeamHelpers     = require '../helpers/team_helpers'
Transaction     = require '../models/transaction'
User            = require '../models/user'
UsersController = require '../app/controllers/users_controller'
UserHelpers     = require '../helpers/user_helpers'

module.exports = (app) ->

  redirect = '/rounds'

  handleError = (req, res, error, redirect) ->
    if req.params.format is 'json'
      res.contentType 'application/json'
      res.send JSON.stringify(error: error)
    else
      req.flash 'error', error
      res.redirect redirect

  app.param 'id', (req, res, next, id) ->
    User.findOne(_id: req.params.id).populate('team').run (err, user) ->
      return next(err)  if err
      return next(new Error('Failed loading user ' + id))  unless user
      req.theUser = user
      next()

  app.get '/user/dash', AuthHelpers.loggedIn, RoundHelpers.loadCurrentRound, (request, response) ->
    new UsersController().dash(request, response)

  app.get '/users.:format?', AuthHelpers.restricted, (request, response) ->
    new UsersController().index(request, response)

  app.get '/users/new', AuthHelpers.restricted, (request, response) ->
    new UsersController().new(request, response)

  app.post '/users', AuthHelpers.restricted, (request, response) ->
    new UsersController().create(request, response)

  app.get '/user/:id.:format?', AuthHelpers.restricted, (request, response) ->
    new UsersController().show(request, response)

  app.get '/user/:id/edit', AuthHelpers.restricted, (request, response) ->
    new UsersController().edit(request, response)

  app.put '/users/:id', AuthHelpers.restricted, (request, response) ->
    new UsersController().update(request, response)

  app.del '/user/:id', AuthHelpers.restricted, (request, response) ->
    new UsersController().delete(request, response)

  app.get '/teams.:format?', (req, res) ->
    if req.params.format is 'json'
      TeamHelpers.getUserInvestable req.user, (err, teams) ->
        return SystemHelpers.error(req, res, err)  if err
        res.contentType 'application/json'
        res.send JSON.stringify(teams)
    else
      Team.find({}).asc('name').populate('users').run (err, teams) ->
        return SystemHelpers.error(req, res, err, '/')  if err
        res.render 'teams/index',
          title: 'List of Teams'
          teams: (if (teams) then teams else [])

  app.get '/teams/new', AuthHelpers.restricted, (req, res) ->
    res.render 'teams/new',
      title: 'New Team'

  app.post '/teams', AuthHelpers.restricted, (req, res) ->
    team = new Team(req.body.team)
    team.save (err) ->
      req.flash 'notice', 'Created.'
      res.redirect '/team/' + team._id

  app.param 'teamId', AuthHelpers.restricted, (req, res, next, id) ->
    Team.findOne(
      _id: id
    , (err, team) ->
      return next(err)  if err
      return next(new Error('Failed loading team ' + id))  unless team
      req.team = team
      next()
    ).populate 'users'

  app.get '/team/:teamId.:format?', AuthHelpers.restricted, (req, res) ->
    if req.params.format is 'json'
      res.contentType 'application/json'
      res.send JSON.stringify(req.team)
    else
      res.render 'teams/show',
        title: req.team.name
        team: req.team

  app.get '/team/:teamId/edit', AuthHelpers.restricted, (req, res) ->
    res.render 'teams/edit',
      title: 'Edit ' + req.team.name
      team: req.team

  app.put '/teams/:teamId', AuthHelpers.restricted, (req, res) ->
    team = req.team
    team.name = req.body.team.name  if req.body.team.name
    team.save (err, doc) ->
      throw err  if err
      req.flash 'notice', 'Updated successfully'
      res.redirect '/team/' + team._id

  app.del '/team/:teamId', AuthHelpers.restricted, (req, res) ->
    team = req.team
    team.remove (err) ->
      req.flash 'notice', 'Deleted'
      res.redirect '/teams'

  handleError = (req, res, error, redirect) ->
    if req.params.format is 'json'
      res.contentType 'application/json'
      res.send JSON.stringify(error: error)
    else
      req.flash 'error', error
      res.redirect redirect

  app.get '/rounds', AuthHelpers.restricted, TeamHelpers.loadTeamCount, (req, res) ->
    Round.find({}).asc('number').run (err, rounds) ->
      res.render 'rounds/index',
        title: 'Rounds'
        rounds: rounds
        teamCount: req.teamCount

  app.post redirect, AuthHelpers.restricted, (req, res) ->
    Round.count {}, (err, numRounds) ->
      return err  if err
      isCurrentRound = (numRounds is 0)
      round = new Round(
        number: numRounds + 1
        is_current: isCurrentRound
      )
      round.save (err, round) ->
        return err  if err
        req.flash 'notice', 'Round appended.'
        res.redirect redirect

  app.param 'roundNumber', AuthHelpers.restricted, (req, res, next, number) ->
    Round.findOne(number: number).run (err, round) ->
      return next(err)  if err
      return next(new Error('Failed loading round ' + number))  unless round
      req.round = round
      next()

  app.del '/round/:roundNumber', AuthHelpers.restricted, (req, res) ->
    round = req.round
    round.remove (err) ->
      return handleError(req, res, err, redirect)  if err
      req.flash 'notice', 'Removed round'
      res.redirect redirect

  app.get '/rounds/current.:format?', AuthHelpers.restricted, (req, res) ->
    Round.findOne(is_current: true).run (err, round) ->
      if req.params.format is 'json'
        res.contentType 'application/json'
        res.send JSON.stringify(round)
      else
        res.render 'rounds/current',
          title: 'Current Round'
          round: round

  #edit the round - toggle open/close or move to the next round
  app.put '/round/:roundNumber', AuthHelpers.restricted, (req, res) ->
    round = req.round
    round.is_open = (req.body.round.is_open.toLowerCase() is 'true')  if req.body.round.is_open
    if req.body.round.next_round
      round.is_current = false
      round.is_open = false
    round.save (err) ->
      return handleError(req, res, err, redirect)  if err
      if req.body.round.next_round
        Round.findOne(number: req.round.number + 1).run (err, round) ->
          return handleError(req, res, err, redirect)  if err
          return handleError(req, res, 'no round found.', redirect)  unless round
          round.is_current = true
          round.save (err) ->
            return handleError(req, res, err, redirect)  if err
            req.flash 'notice', 'Round progressed.'
            res.redirect redirect
      else
        req.flash 'notice', 'Round toggled.'
        res.redirect redirect

  app.put '/round/:roundNumber/process', AuthHelpers.restricted, (req, res) ->
    return handleError(req, res, 'cannot process again.', redirect) if req.round.processed
    Rounds.process req.round, (err) ->
      return handleError(req, res, err, redirect) if err
      req.flash 'notice', 'Round ' + req.round.number.toString() + ' processed.'
      res.redirect redirect

  app.post '/round/:roundNumber/allocate', AuthHelpers.restricted, (req, res) ->
    Allocation.process req.round, new Number(req.body.allocate.amount), (err) ->
      return handleError(req, res, err, redirect) if err
      req.flash 'notice', 'Allocated funds to all users for round ' + req.round.number.toString() + '.'
      res.redirect redirect

  app.post '/rounds/reset', AuthHelpers.restricted, (req, res) ->
    Reset.process (err) ->
      return handleError req, res, err, redirect if err
      req.flash 'notice', 'tilt has been reset.'
      res.redirect redirect

  app.get '/results.:format?', RoundHelpers.loadCurrentRound, (req, res) ->
    Result.find({}).populate('round', null, {},
      sort: 'number'
    ).populate('team', null, {},
      sort: 'name'
    ).run (err, results) ->
      roundResults = []
      results.forEach (result) ->
        singleRoundResults = []
        unless roundResults[result.round.number - 1]
          roundResults[result.round.number - 1] = singleRoundResults
        else
          singleRoundResults = roundResults[result.round.number - 1]
        singleRoundResults.push result
        singleRoundResults.sort (a, b) ->
          a.team.name > b.team.name

      if req.params.format is 'json'
        res.contentType 'application/json'
        res.send JSON.stringify(roundResults)
      else
        lastResultRound = 1
        lastResultRound = (if (req.currentRound.processed) then req.currentRound.number else Math.max(req.currentRound.number - 1, 1))  if req.currentRound
        roundResults.reverse()
        res.render 'results/index',
          title: 'Current Results'
          results: roundResults
          lastResultRound: lastResultRound
          currentRound: req.currentRound

  app.get '/investment/new', AuthHelpers.loggedIn, RoundHelpers.loadCurrentRound, (req, res) ->
    TeamHelpers.getUserInvestable req.user, (err, teams) ->
      return SystemHelpers.error(req, res, err)  if err
      res.render 'investments/new',
        title: 'New Investment'
        teams: teams
        currentRound: req.currentRound

  app.post '/investments.:format?', AuthHelpers.loggedIn, RoundHelpers.loadCurrentRound, (req, res) ->
    console.log req.body
    return handleError(req, res, 'Not authorized.', '/')  if req.body.investment.user and not req.user.is_admin
    user = req.body.investment.user or req.user
    user = User.findOne(_id: user._id or user).run (err, user) ->

      return handleError(req, res, 'invalid user', '/investment/new')  if err

      if !req.body.investment.investments
        req.body.investment.investments = []
        for prop of req.body.investment
          req.body.investment.investments[prop.split('_')[1]] = req.body.investment[prop]  if prop.substring(0, 5) is 'team_'

      return handleError(req, res, 'no current round.', '/investment/new') unless req.currentRound
      return handleError(req, res, 'cannot invest - round no longer open.', '/investment/new')  unless req.currentRound.is_open

      Process.investments user, req.body.investment.investments, req.currentRound, (err, investments) ->
        return handleError(req, res, err, '/investment/new') if err
        if req.params.format is 'json'
          res.contentType 'application/json'
          res.send JSON.stringify(investments)
        else
          req.flash 'notice', 'invested successfully.'
          if req.user.is_admin
            res.redirect '/investment/new'
          else
            res.redirect '/user/dash'

  app.get '/', (req, res) ->
    res.render 'index',
      title: 'tilt'
