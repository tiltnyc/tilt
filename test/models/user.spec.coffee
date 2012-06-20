{should, clean} = require "../test-base"

User = require "../../models/user"
Team = require "../../models/team"
  
describe "User", ->
  user = undefined 
  teamA = undefined
  teamB = undefined 

  beforeEach (done) ->
    user = new User
      username: 'justin'
      email: 'justin@example.com'
    
    teamA = new Team
      name: 'teamA'
    teamA.save (err) ->
      throw err if err
      teamB = new Team
        name: 'teamB'
      teamB.save (err) ->
        throw err if err
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
