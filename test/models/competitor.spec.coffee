{should, clean, factory} = require "../test-base"

Competitor = require "../../models/competitor"
Team = require "../../models/team"
Event = require "../../models/event"
  
describe "Competitor", ->
  user = undefined 
  userB = undefined
  competitor = undefined
  competitorB = undefined
  event = undefined
  teamA = undefined
  teamB = undefined 

  beforeEach (done) ->    
    factory.starter 2, (result) ->
      user = result.users[0]
      userB = result.users[1]
      competitor = result.competitors[0]
      competitorB = result.competitors[1]
      teamA = result.teams[0]
      teamB = result.teams[1]
      event = result.event 
      done()

  afterEach (done) ->
    clean done

  it "saving a competitor without a team is ok", (done) ->
    competitor.save (err, c) ->
      throw err if err 
      c.should.not.have.property('team')
      done()

  it "setting a team to a competitor should add the competitor to the team", (done) ->
    competitor.addToTeam teamA
    competitor.save (err, c) ->
      throw err if err
      Competitor.findById(competitor.id).populate('team').exec (err, u) ->
        u.team.name.should.eql teamA.name
        u.team.competitors.should.include(competitor.id)  
        Team.findById(u.team.id).exec (err, t) ->
          t.competitors.indexOf(c.id).should.be.above(-1) 
          done()

  it "replacing the team should remove the competitor from old team and add to new", (done) ->
    competitor.addToTeam teamA
    competitor.save (err, c) ->
      throw err if err
      competitor.addToTeam teamB
      competitor.save (err, c) ->
        throw err if err
        Competitor.findById(competitor.id).populate('team').exec (err, u) ->
          u.team.name.should.eql teamB.name
          u.team.competitors.should.include(competitor.id)   
          Team.findById(teamA._id).exec (err, t) ->
            throw err if err
            t.competitors.should.not.include(competitor.id)
            done()

  it "adding a competitor to a team with existing competitors should append to the team's list of competitors", (done) ->
    competitor.addToTeam teamA
    competitor.save (err) ->
      throw err if err
      competitorB.addToTeam teamA
      competitorB.save (err) ->
        throw err if err
        Competitor.findById(competitor.id).populate('team').exec (err, c) ->
          c.team.competitors.should.include(competitor.id)   
          c.team.competitors.should.include(competitorB.id)
          Team.findById(teamA.id).populate("competutors").exec (err, t) ->
            t.competitors.length.should.eql 2  
            done()
