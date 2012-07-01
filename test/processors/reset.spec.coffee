{should, clean, create} = require "../test-base"

Reset = require "../../processors/reset"
User = require "../../models/user"
Round = require "../../models/round" 

describe "Reset Process", ->
  userA = undefined
  userB = undefined
  teamA = undefined
  round = undefined

  beforeEach (done) ->
   done()

  it "must wipe all user funds, unprocess all rounds, remove investments, transactions, results and team scores"