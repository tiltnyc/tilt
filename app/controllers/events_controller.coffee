BaseController = require './base_controller'
Event          = require '../../models/event'

class EventsController extends BaseController

  setParam: (request, response, next, id) ->
    Event.findById(id).exec (err, event) ->
      return next(err) if err
      request.event = event
      next()

  index: (request, response) ->
    Event.find().sort("date", "ascending").exec (error, events) ->
      throw error if error

      if request.params.format is 'json'
        response.contentType 'application/json'
        response.send JSON.stringify(events)
      else
        response.render 'events/index',
          title: 'List of Events'
          events: events

  new: (request, response) ->
    response.render 'events/new',
      title: 'New Event'

  create: (request, response) ->
    event = new Event(request.body.event)
    event.save (error) ->
      throw error if error
      request.flash 'notice', 'Created.'
      response.redirect '/event/' + event._id

  show: (request, response) ->
    if request.params.format is 'json'
      response.contentType 'application/json'
      response.send JSON.stringify(request.event)
    else
      response.render 'events/show',
        title: request.event.name
        event: request.event

  edit: (request, response) ->
    response.render 'events/edit',
      title: "Edit #{request.event.name}"
      event: request.event

  update: (request, response) ->
    event = request.event
    @updateIfChanged ["name", "date"], event, request.body.event
    event.save (err) ->
      throw err if err
      request.flash 'notice', 'Updated successfully'
      response.redirect '/event/' + event._id

  delete: (request, response) ->
    #todo - should not delete if any competitors
    request.event.remove (error) ->
      request.flash 'notice', 'Deleted'
      response.redirect '/events'

module.exports = EventsController