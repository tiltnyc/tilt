{ should, clean, factory } = require '../test-base'

Event = require '../../models/event'

describe 'Event', ->
  eventOne = undefined

  beforeEach (done) ->
    eventOne = new Event({name: 'Event One'})
    eventOne.save (error) ->
      throw error if error
      done()

  afterEach (done) ->
    clean done

  it 'creates a _slug from the name', ( done ) ->
    event = new Event({name: 'Event Two'})
    event.save (error) ->
      throw error if error
      event._slug.should.eql 'event-two'
      done()

  it '.findBySlug finds by slug', ( done ) ->
    Event.findBySlug eventOne._slug, (error, event) ->
      throw error if error
      event._id.should.eql eventOne._id
      done()

  it '.findById finds by id', ( done ) ->
    Event.findById eventOne._id, (error, event) ->
      throw error if error
      event._id.should.eql eventOne._id
      done()

  it '.findById finds by slug', ( done ) ->
    Event.findById eventOne._slug, (error, event) ->
      throw error if error
      event._id.should.eql eventOne._id
      done()
