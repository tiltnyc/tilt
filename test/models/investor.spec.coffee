{should, clean, factory} = require "../test-base"

Investor = require "../../models/investor"
Team = require "../../models/team"
Event = require "../../models/event"
  
describe "Investor", ->
  user = undefined 
  userB = undefined
  investorA = undefined
  investorB = undefined
  event = undefined
  teamA = undefined
  teamB = undefined 

  beforeEach (done) ->    
    factory.starter 2, (result) ->
      user = result.users[0]
      userB = result.users[1]
      investorA= result.investors[0]
      investorB = result.investors[1]
      teamA = result.teams[0]
      teamB = result.teams[1]
      event = result.event 
      done()

  afterEach (done) ->
    clean done

  it "must allocate funds into any round number", (done) ->
    investorA.getFundsForRoundNbr(1).should.eql 0  
    investorA.addFundsForRoundNbr 2, 100
    investorA.getFundsForRoundNbr(1).should.eql 0
    investorA.getFundsForRoundNbr(2).should.eql 100
    investorA.addFundsForRoundNbr 2, 150
    investorA.getFundsForRoundNbr(2).should.eql 250
    investorA.addFundsForRoundNbr(2, -50.5)
    investorA.getFundsForRoundNbr(2).should.eql 199.5
    done()
    
    

