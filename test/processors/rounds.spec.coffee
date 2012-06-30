{should, clean} = require "../test-base"

#Process = require "../../processors/rounds.coffee"

Investment = require "../../models/investment"
User = require "../../models/user"
Team = require "../../models/team"
Round = require "../../models/round" 


describe "Round Process", ->
  beforeEach (done) ->


  afterEach (done) -> clean done  

  it "should correctly handle a round's process" 
