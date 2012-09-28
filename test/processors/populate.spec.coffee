{should, clean, factory} = require "../test-base"

populator = require "../../processors/populate"
Team = require "../../models/team"
User = require "../../models/user"
Event = require "../../models/event"

describe "Event Population", () ->
  event = undefined
  userlist = """
  paul\tsmith\tdes_ps@g.com\tdesigner 
  john\ttame\teng_j@g.com\tengineer
  ian\t\tmar_c@x.com\tmarketing 
  john\ttame\tinv_x@y.com\tinvestor
  bob\ttate\teng_n@sd.com\tengineer
  \t\tdes_x@sdd.com\tdesigner
  ian\t\tmar_c@as.com\tmarketing 
  john\ttame\tdes_x@yd.com\tdesigner
  b\ttde\teng_n@sdd.com\tengineer
  b\ttde\tinv_n@3.com\tinvestor
  b\ttde\tstr_n@5.com\tstrategy
  x\ttde\tdes_n@8.com\tdesigner
  x\ttde\teng_n@9.com\tengineer
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
    @timeout(5000)
    team = new Team
      event: event.id
      name: "test123"
    team.save () ->
      populator userlist, event, 1, (results) ->
        results.should.be.a('string')
        done()

  it "must not recreate an existing user", (done) ->
    @timeout(5000)
    factory.create User,
      email: "des_ps@g.com"
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
    @timeout(5000)
    populator userlist, event, 4, (results) ->
      results.length.should.eql 4
      results[0].competitors.length.should.eql 4
      results[1].competitors.length.should.eql 4
      results[2].competitors.length.should.eql 4
      results[3].competitors.length.should.eql 1
      done()