{should, clean, create} = require "../test-base"

#Process = require "../../processors/rounds.coffee"

Investment = require "../../models/investment"
User = require "../../models/user"
Team = require "../../models/team"
Round = require "../../models/round" 

describe "Round Process", ->
  userA = undefined
  userB = undefined
  teamA = undefined
  teamB = undefined
  teamC = undefined
  round = undefined

  beforeEach (done) ->
    userA = create User, {name: 'justin', email: 'j@example.com'}, () ->
      userB = create User, {name: 'paul', email: 'p@example.com'}, () ->
        teamA = create Team, name: 'teamA', () ->
          teamB = create Team, name: 'teamB', () ->
            teamC = create Team, name: 'teamC', () ->
              round = create Round, number: 1,  () -> done()

  afterEach (done) -> clean done  

  it "should correctly handle a round's process, configuration A"
    #set investments
    #done()
