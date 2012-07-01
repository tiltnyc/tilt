{should, clean, create} = require "../test-base"

Process = require "../../processors/rounds"

Investment = require "../../models/investment"
User = require "../../models/user"
Team = require "../../models/team"
Round = require "../../models/round" 

describe "Round Process", ->
  userA = undefined
  userB = undefined
  userC = undefined
  teamA = undefined
  teamB = undefined
  teamC = undefined
  round1 = undefined

  beforeEach (done) ->
    userA = create User, {name: 'justin', email: 'j@example.com'}, () ->
      userB = create User, {name: 'paul', email: 'p@example.com'}, () ->
        userC = create User, {name: 'fred', email: 'f@example.com'}, () ->
          teamA = create Team, name: 'teamA', () ->
            teamB = create Team, name: 'teamB', () ->
              teamC = create Team, name: 'teamC', () ->
                round1 = create Round, number: 1,  () -> done()

  afterEach (done) -> clean done

  invest = (user, team, percentage, done) ->
    create Investment, 
      user: user._id
      team: team._id
      round: 1
      percentage: percentage
    , () -> done()

  it "must valuate teams and reward investors for round 1", (done) ->
    #allocate users money...
    invest userA, teamA, 0.5, () ->
      invest userA, teamB, 0.5, () ->
        invest userB, teamA, 1, () ->
          Process.rounds round1, round1, 3, (err) ->
            throw err if err
            #todo: check values...
            done()

  it "must valuate teams and reward investors for round 2"
