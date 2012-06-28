{should, clean} = require "../test-base"

Process = require "../../processors/investments.coffee"

Investment = require "../../models/investment"
User = require "../../models/user"
Team = require "../../models/team"
Round = require "../../models/round" 

describe "Investment Process", ->
  teamA = new Team
    name: 'teamA'
  teamB = new Team
    name: 'teamB'
  teamC = new Team
    name: 'teamC'
  user = new User
    username: 'justin'
    email: 'justin@example.com' 
  round = undefined

  beforeEach (done) ->
    teamA.save (err) ->
      throw err if err
      teamB.save (err) ->
        throw err if err
        teamC.save (err) ->
          throw err if err
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
        inv.user.should.eql user._id
        inv.percentage.should.eql investments[i].percentage
      done()

  it "must cap investments at 100%", (done) ->
    investments = 
    [
      team: teamA
      percentage: 0.8
    ,
      team: teamB
      percentage: 0.7
    ,
      team: teamC
      percentage: 0.3
    ]
    Process.investments user, investments, round, (err, results) ->
      throw err if err
      results[0].percentage.should.eql investments[0].percentage
      results[1].percentage.should.eql Math.roundToFixed(1 - results[0].percentage, 2)
      results[2].percentage.should.eql Math.roundToFixed(1 - results[0].percentage - results[1].percentage, 2)
      done()

  it "only accepts investments between 0 and 1", (done) ->
    investments = 
    [
      team: teamA
      percentage: -1
    ,
      team: teamB
      percentage: "justin"
    ,
      team: teamC
      percentage: 0.4
    ]
    Process.investments user, investments, round, (err, results) ->
      throw err if err
      results[0].percentage.should.eql 0
      results[1].percentage.should.eql 0
      results[2].percentage.should.eql investments[2].percentage
      done()

  it "must replace existing round investments", (done) ->
    old_investments = 
    [
      team: teamA
      percentage: 1
    ]
    Process.investments user, old_investments, round, (err, results) ->
      throw err if err
      new_investments = 
      [
        team: teamA
        percentage: 0.5
      ,
        team: teamC
        percentage: 0.45 
      ]  
      Process.investments user, new_investments, round, (err, results) ->
        throw err if err
        Investment.find
          round: round.number
          user: user
        .run (err, investments) ->
          investments.length.should.eql 2
          for i in investments
            if i.team.toString() is teamA._id.toString() then i.percentage.should.eql 0.5
            else if i.team.toString() is teamC._id.toString() then i.percentage.should.eql 0.45
            else throw "invalid result"
          done()

  it "must not allow investment in closed round", (done) ->
    round.is_open = false
    round.save (err) ->
      throw err if err
      investments = 
      [
        team: teamA
        percentage: 0.4
      ,
        team: teamB
        percentage: 0.6
      ]
      Process.investments user, investments, round, (err, results) ->
        should.exist err
        done()
     
  it "must override duplicate investments within the one process with the latest entry", (done) ->
    investments = 
    [
      team: teamA
      percentage: 0.5
    ,
      team: teamB
      percentage: 0.4
    ,
      team: teamA
      percentage: 0.6
    ]
    Process.investments user, investments, round, (err, results) ->
      throw err if err
      Investment.find
        round: round.number
        user: user
      .run (err, investments) ->
        investments.length.should.eql 2
        for i in investments
          if i.team.toString() is teamA._id.toString() then i.percentage.should.eql 0.5
          else if i.team.toString() is teamB._id.toString() then i.percentage.should.eql 0.4
          else throw "invalid result"
        done()
  