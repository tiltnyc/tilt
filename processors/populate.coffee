User = require("../models/user")
Team = require("../models/team")
Competitor = require("../models/competitor")
bcrypt = require('bcrypt')

module.exports = (userlist, event, usersInTeam, done) ->
  data = require '../data/us_cities'
  passcodes = {}

  popRandomData = () ->
    i = Math.floor(Math.random() * data.length)
    data.splice(i, 1)[0]

  Team.find(event: event.id).exec (err, teams) ->

    return done "cannot populate, teams exist" if teams.length

    rows = userlist.split('\n')
    usersByRole = {}
    totalUsers = 0 

    processUsers = (r, rowsDone) ->
      next = () -> processUsers r+1, rowsDone
      return rowsDone() if r >= rows.length
      row = rows[r]
      [fname, lname, email, role, twitter] = row.split('\t')
      return next() unless email
      role = role.toLowerCase()
      User.findOne(email: email.trim()).exec (err, user) ->
        salt = bcrypt.genSaltSync(10)
        passcode = popRandomData().city.replace(/\s+/g, "").toLowerCase() + Math.round(Math.random() * 100)
        hash = bcrypt.hashSync(passcode, salt)
        passcodes[email.trim()] = passcode
        if user
          console.log "found user #{email}, updating"
          user.fname = fname.trim() if fname?.trim()
          user.lname = lname.trim() if lname?.trim()
          user.role = role.trim() if role?.trim()
          user.twitter = twitter.trim() if twitter?.trim()
          user.salt = salt
          user.hash = hash
        else
          console.log "creating user #{email}"
          user = new User
            fname: fname?.trim() ? ""
            lname: lname?.trim() ? ""
            email: email?.trim() ? ""
            role: role?.trim() ? ""
            twitter: twitter?.trim() ? ""
            username: twitter?.trim() ? "#{fname}.#{lname}" 
            salt: salt
            hash: hash
        user.save (err, u) ->
          usersByRole[u.role]?= []
          usersByRole[u.role].push(u)
          totalUsers++
          next()

    processUsers 0, () ->
      nextRoleIndex = 0
      roles = Object.keys(usersByRole)
      popUser = (r = nextRoleIndex) ->
        return if totalUsers is 0
        return popUser(0) if r >= roles.length
        if usersByRole[roles[r]].length
          nextRoleIndex = r+1
          totalUsers--
          return usersByRole[roles[r]].shift()
        else
          return popUser(r+1)

      numTeams = Math.ceil(totalUsers / usersInTeam)
      teams = []
      processTeams = (i, teamsDone) ->
        return teamsDone() if i >= numTeams
        team = new Team
          event: event.id
          name: popRandomData().city
        team.save (err, team) ->
          console.log "created team: " + team.name if usersInTeam > 1
          processCompetitor = (c, competitorDone) ->
            return competitorDone() if c >= usersInTeam
            user = popUser() 
            return competitorDone() if !user #ran out of users
            competitor = new Competitor
              user: user.id
              event: event.id
              team: team.id
            competitor.save (err, competitor) ->
              processCompetitor c+1, competitorDone
              console.log "added competitor #{user.email} to #{team.name}" if usersInTeam > 1
          processCompetitor 0, () ->
            processTeams i+1, teamsDone  
            

      processTeams 0, () -> 
        Team.find(event: event.id).exec (err, teams) -> 
          done 
            teams: teams
            passcodes: passcodes

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
