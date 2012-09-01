{should, clean, factory} = require "../test-base"

User = require "../../models/user"
Team = require "../../models/team"
Event = require "../../models/event"
  
describe "User", ->
  user = undefined 
  event = undefined
  teamA = undefined
  teamB = undefined 

  beforeEach (done) ->    
    factory.starter 2, (result) ->
      user = result.users[0]
      teamA = result.teams[0]
      teamB = result.teams[1]
      event = result.event 
      done()

  afterEach (done) ->
    clean done

  it "saving a user without a team is ok", (done) ->
    user.save (err) ->
      throw err if err 
      user.should.not.have.property('team')
      done()

  it "setting a team to a user should add the user to the team", (done) ->
    user.addToTeam teamA
    user.save (err) ->
      throw err if err
      User.findById(user).populate('team').exec (err, u) ->
        u.team.name.should.eql teamA.name
        u.team.users.should.include(user._id)   
        done()

  it "replacing the team should remove the user from old team and add to new", (done) ->
    user.addToTeam teamA
    user.save (err) ->
      throw err if err
      user.addToTeam teamB
      user.save (err) ->
        throw err if err
        User.findById(user).populate('team').exec (err, u) ->
          u.team.name.should.eql teamB.name
          u.team.users.should.include(user._id)   
          Team.findById(teamA._id).exec (err, t) ->
            throw err if err
            t.users.should.not.include(user._id)
            done()

  it "adding a user to a team with existing users should append to the team's list of users", (done) ->
    user.addToTeam teamA
    user.save (err) ->
      throw err if err
      userB = new User
        username: 'paul'
        email: 'paul@example.com'
      userB.addToTeam teamA
      userB.save (err) ->
        throw err if err
        User.findById(user).populate('team').exec (err, u) ->
          u.team.users.should.include(user._id)   
          u.team.users.should.include(u._id)
          done()
