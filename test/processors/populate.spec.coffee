{should, clean, factory} = require "../test-base"

populator = require "../../processors/populate"
Team = require "../../models/team"
User = require "../../models/user"
Event = require "../../models/event"

describe "Event Population", () ->
  event = undefined
  userlist = """
  paul\tsmith\tps@g.com\tdesigner 
  john\ttame\tj@g.com\tengineer
  ian\t\tc@x.com\tdesigner 
  john\ttame\tj@g.com\tengineer
  """
  beforeEach (done) ->  
    factory.create Event,
      name: "test"
      date: new Date()
    , (evt) -> 
      event = evt
      done()

  afterEach (done) -> clean done

  it "must not populate if event has teams", (done) ->
    team = new Team
      event: event.id
      name: "test123"
    team.save () ->
      populator userlist, event, 1, (results) ->
        results.should.be.a('string')
        done()

  it "must not recreate an existing user", (done) ->
    factory.create User,
      email: "ps@g.com"
      fname: 'first'
      lname: 'last'
      role: 'x'
      twitter: ''
    , (user) ->
      populator userlist, event, 1, (results) ->
        User.findById(user.id).exec (err, u) ->
          u.fname.should.eql "paul"
          u.lname.should.eql "smith"
          done()

  it "must do something", (done) ->
    populator userlist, event, 1, (results) ->
      done()