{should, clean, factory} = require "../test-base"

Process = require "../../processors/investments.coffee"

Investment = require "../../models/investment"
Investor = require "../../models/investor"
Team = require "../../models/team"
Round = require "../../models/round"

describe "Investment Process", ->
  user = undefined
  investor = undefined
  teamA = undefined
  teamB = undefined
  teamC = undefined
  round = undefined

  beforeEach (done) ->
   factory.starter 3, (result) ->
      user = result.users[0]
      investor = result.investors[0]
      teamA = result.teams[0]
      teamB = result.teams[1]
      teamC = result.teams[2]
      round = result.rounds[0]
      event = result.event
      round.is_current = true
      round.is_open = true
      round.save (err) ->
        throw err if err
        done()

  afterEach (done) -> clean done

  it "must save investments as entered", (done) ->
    investments =
    [
      team: teamA._id
      percentage: 0.4
    ,
      team: teamB._id
      percentage: 0.6
    ]
    Process.investments investor, investments, round, (err, results) ->
      throw err if err
      for inv, i in results
        inv.team.should.eql investments[i].team
        inv.investor.should.eql investor._id
        inv.percentage.should.eql investments[i].percentage
      done()

  it "must cap investments at 100%", (done) ->
    investments =
    [
      team: teamA._id
      percentage: 0.8
    ,
      team: teamB._id
      percentage: 0.7
    ,
      team: teamC._id
      percentage: 0.3
    ]
    Process.investments investor, investments, round, (err, results) ->
      throw err if err
      results[0].percentage.should.eql investments[0].percentage
      results[1].percentage.should.eql Math.roundToFixed(1 - results[0].percentage, 2)
      results[2].percentage.should.eql Math.roundToFixed(1 - results[0].percentage - results[1].percentage, 2)
      done()

  it "only accepts investments between 0 and 1", (done) ->
    investments =
    [
      team: teamA._id
      percentage: -1
    ,
      team: teamB._id
      percentage: "justin"
    ,
      team: teamC._id
      percentage: 0.4
    ]
    Process.investments investor, investments, round, (err, results) ->
      throw err if err
      results[0].percentage.should.eql 0
      results[1].percentage.should.eql 0
      results[2].percentage.should.eql investments[2].percentage
      done()

  it "must replace existing round investments", (done) ->
    old_investments =
    [
      team: teamA._id
      percentage: 1
    ]
    Process.investments investor, old_investments, round, (err, results) ->
      throw err if err
      new_investments =
      [
        team: teamA._id
        percentage: 0.5
      ,
        team: teamC._id
        percentage: 0.45
      ]
      Process.investments investor, new_investments, round, (err, results) ->
        throw err if err
        Investment.find
          round: round
          investor: investor
        .exec (err, investments) ->
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
        team: teamA._id
        percentage: 0.4
      ,
        team: teamB._id
        percentage: 0.6
      ]
      Process.investments investor, investments, round, (err, results) ->
        should.exist err
        done()

  it "must override duplicate investments within the one process with the latest entry", (done) ->
    investments =
    [
      team: teamA._id
      percentage: 0.5
    ,
      team: teamB._id
      percentage: 0.4
    ,
      team: teamA._id
      percentage: 0.6
    ]
    Process.investments investor, investments, round, (err, results) ->
      throw err if err
      Investment.find
        round: round
        investor: investor
      .exec (err, investments) ->
        investments.length.should.eql 2
        for i in investments
          if i.team.toString() is teamA._id.toString() then i.percentage.should.eql 0.5
          else if i.team.toString() is teamB._id.toString() then i.percentage.should.eql 0.4
          else throw "invalid result"
        done()
