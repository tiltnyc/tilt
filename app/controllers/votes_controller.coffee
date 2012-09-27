mongoose = require("mongoose")

BaseController = require './base_controller'
User = require '../../models/user'
Vote = require '../../models/vote'
Competitor = require '../../models/competitor'
TeamHelpers     = require '../../helpers/team_helpers'

class VotesController extends BaseController

  new: (request, response) ->
    TeamHelpers.getTeamsExceptUsers request.currentEvent, request.user, request.currentCompetitor, (err, teams) =>
      return @error(request, response, err, '/') if err
      response.render 'votes/new',
        title: 'Vote for Teams'
        teams: teams
        currentRound: request.currentRound
  
  create: (request, response) ->

    error = (msg) => @error(request, response, msg, '/vote/new') 
    return error 'Not authorized' if request.body.vote.competitor and not request.user.is_admin
    return error "Admin isn't setup to invest"  if request.user.is_admin and not request.body.vote.competitor and not request.currentCompetitor
    return error 'cannot invest - no currently open round' unless request.currentRound
    return error 'cannot invest - round no longer open' unless request.currentRound.is_open

    cid = if request.user.is_admin and request.body.vote.competitor then request.body.vote.competitor else request.currentCompetitor.id

    Competitor.findById(cid).exec (err, competitor) ->
      return error err if err
      return "cannot invest - not setup as competitor" if !competitor

      teams = request.body.vote.teams.split ","

      #remove old votes
      Vote.find(competitor: cid, round: request.currentRound.id).remove () ->
        votes = []  
        processVote = (i, done) ->
          return done() if i >= teams.length 
          team = teams[i].replace(/\"/g, "")
          return processVote i+1, done if competitor.team and competitor.team.toString() is team
          vote = new Vote
            team: team
            competitor: competitor.id
            round: request.currentRound.id
            event: request.currentEvent.id
          vote.save (err, v) -> 
            throw err if err
            votes.push v
            processVote i+1, done
            console.log "here", i  

        processVote 0, () ->
          if request.params.format is 'json'
            response.contentType 'application/json'
            response.send JSON.stringify(votes)
          else
            request.flash 'notice', 'voted successfully.'
            if request.user.is_admin
              response.redirect '/vote/new'
            else
              response.redirect '/competitor/dash' 


module.exports = VotesController