{should, clean} = require "../test-base"

Process = require "../../processors/investments.coffee"

User = require "../../models/user"
Team = require "../../models/team"
Round = require "../../models/round" 

describe "Investment Process", ->
  teamA = undefined
  teamB = undefined
  user = undefined 
  round = undefined

  beforeEach (done) ->
    teamA = new Team
      name: 'teamA'
    teamA.save (err) ->
      throw err if err
      teamB = new Team
        name: 'teamB'
      teamB.save (err) ->
        throw err if err
        user = new User
          username: 'justin'
          email: 'justin@example.com'
        user.save (err) ->
          throw err if err
          round = new Round
            number: 1
            is_current: true
            is_open: true
          round.save (err) ->
            throw err if err
            done()

  afterEach (done) -> clean done

  it "must save investments as entered", (done) ->
    investments = 
    [
      team: teamA
      percentage: 0.4
    ,
      team: teamB
      percentage: 0.6
    ]
    Process.investments user, investments, round, (err, results) ->
      throw err if err
      for inv, i in results
        inv.team.should.eql investments[i].team._id
        inv.percentage.should.eql investments[i].percentage
      done()

  it "must cap investments at 100%"

  it "must replace existing round investments"

  it "must not allow investment in closed round"

  it "must override duplicate investments within the one process with the latest entry"
