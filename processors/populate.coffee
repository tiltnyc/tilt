User = require("../models/user")
Team = require("../models/team")
bcrypt = require('bcrypt')

module.exports = (userlist, event, numTeams, done) ->
  data = require '../data/us_cities'

  Team.find(event: event.id).exec (err, teams) ->

    return done "cannot populate, teams exist" if teams.length

    rows = userlist.split('\n')
    usersByRole = {}

    processUsers = (r, rowsDone) ->
      next = () -> processUsers r+1, rowsDone
      return rowsDone() if r >= rows.length
      row = rows[r]
      [fname, lname, email, role, twitter] = row.split('\t')
      return next() unless email
      User.findOne(email: email.trim()).exec (err, user) ->
        if user
          user.fname = fname.trim() if fname?.trim()
          user.lname = lname.trim() if lname?.trim()
          user.role = role.trim() if role?.trim()
          user.twitter = twitter.trim() if twitter?.trim()
        else
          salt = bcrypt.genSaltSync(10)
          user = new User
            fname: fname?.trim() ? ""
            lname: lname?.trim() ? ""
            email: email?.trim() ? ""
            role: role?.trim() ? ""
            twitter: twitter?.trim() ? ""
            username: twitter?.trim() ? "#{fname}.#{lname}" 
            salt: salt
            hash: bcrypt.hashSync("something", salt)
        user.save (err, u) ->
          usersByRole[u.role]?= []
          usersByRole[u.role].push(u)
          next()

    processUsers 0, () ->

      #createAndPopulateTeam = (t, teamsDone) ->


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
