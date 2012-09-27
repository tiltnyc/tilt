{should, clean, factory} = require "../test-base"

populator = require "../../processors/populate"
Team = require "../../models/team"
Event = require "../../models/event"

describe "Event Population", () ->
  event = undefined
  userlist = """
  justinmoses\tjustinjmoses@gmail.com\te\tjustinjmoses
  paul\tsmith\tps@gmail.com\td 

  """
  beforeEach (done) ->
    factory.create Event,
      name: "test"
      date: new Date()
    , (evt) -> 
      event = evt
      done()


  it "must not populate if event has teams", (done) ->
    team = new Team
      event: event.id
      name: "test123"
    team.save () ->
      populator userlist, event, (results) ->
        results.should.be.a('string')
        done()

  it "must break", (done) ->
    populator userlist, event, (results) ->
      done()