BaseController = require './base_controller'
Event          = require '../../models/event'
UploadHelpers  = require '../../helpers/upload_helpers'
EventHelpers  = require '../../helpers/event_helpers'

class GameController extends BaseController

  teamNames = ["architects", "bently", "cyclops", "deltas", "extreme.", "feels like felt", "genesis", "hawking", "impromptu", "juniper", "kelvins", "luminous", "moscow", ""]
  populateIntoTeams: (request, response) ->
    #return unless currentEvent has no teams

    #take CSV
      #for each entry
        #create or load a user
        #put user into category box

      #for each team wanted
        #create a team (take random US city name)
        #for each category
          #if empty, choose fullest category
          #shift off user
          #assign user to team



module.exports = GameController