User = require("../models/user")
Team = require("../models/team")
  
module.exports = (userlist, event, done) ->
  data = require '../data/us_cities'

  Team.find(event: event.id).exec (err, teams) ->

    return done "cannot populate, teams exist" if teams.length
    done()
  #teamNames = ["architects", "bently", "cyclops", "deltas", "extreme.", "feels like felt", "genesis", "hawking", "impromptu", "juniper", "kelvins", "luminous", "moscow", ""]
    
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
