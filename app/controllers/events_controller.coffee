BaseController = require './base_controller'
Event          = require '../../models/event'
UploadHelpers  = require '../../helpers/upload_helpers'
EventHelpers   = require '../../helpers/event_helpers'
Investor       = require '../../models/investor'
Competitor     = require '../../models/competitor'
MailHelpers    = require '../../helpers/mail_helpers'
populater      = require '../../processors/populate'

class EventsController extends BaseController

  setParam: (request, response, next, id) ->
    Event.findById(id).exec (err, event) ->
      return next(err) if err
      request.event = event
      next()

  index: (request, response) ->
    Event.find().sort("date", "ascending").exec (error, events) ->
      throw error if error
      EventHelpers.populateTeams events, () ->
        if request.params.format is 'json'
          response.contentType 'application/json'
          response.send JSON.stringify(events)
        else
          response.render 'events/index',
            title: 'tilt events'
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
    URIs = UploadHelpers.getImageURIs request 
    event.picture = URIs[0] if URIs.length
    @updateIfChanged ["name", "date", "venue", "theme"], event, request.body.event
    event.save (err) ->
      throw err if err
      request.flash 'notice', 'Updated successfully'
      response.redirect '/event/' + event.id

  delete: (request, response) ->
    #todo - should not delete if any competitors
    request.event.remove (error) ->
      request.flash 'notice', 'Deleted'
      response.redirect '/events'

  load: (request, response) ->
    request.flash 'notice', "Now viewing event #{request.event.name}"
    request.session.currentEvent = request.event
    response.redirect '/event/' + request.event.id

  admin: (request, response) ->  
    response.render 'events/admin',
      title: "Administer #{request.event.name}"
      event: request.event
      numPasscodes: Object.keys(request.session.passcodes ? {}).length

  mail: (request, response) ->
    Competitor.find(event: request.event.id).populate("user").exec (err, competitors) ->
      recipients = competitors
      from = "justin j. moses"
      fromEmail = "tilt.challenge@gmail.com"
      msg = """
      hey :fname:,


      your tilt account has been created and you've been assigned a team!

      please login via http://live.tiltnyc.net/login to see what's

      use this email (:email:) as login as your passcode is:

      *:password:*


      thanks!
      the tilt team"""
      for recip in recipients
        email = recip.user.email
        if !request.session.passcodes[email]
          #console.log "no passcode for <#{email}>. skipped."
          continue
        fullname = if recip.user.fname and recip.user.fname then "\"#{recip.user.fname} #{recip.user.lname}\"" else "" 
        password = request.session.passcodes[email]
        body = msg.replace(":password:", password).replace(":fname:", recip.user.fname).replace(":lname:", recip.user.lname).replace(":email:", email)
        MailHelpers.send [email, fullname], [fromEmail, from], "your TILT login", body, [fromEmail]
        #console.log "sending to #{fullname} <#{email}>"
      request.flash 'notice', "Emailed #{recipients.length} Recipients"
      response.redirect '/events'

  populate: (request, response) ->
    populater request.body.userlist, request.event, 4, (results) ->
      if typeof results is 'string'
        request.flash 'error', results
      else
        #console.log results.passcodes
        request.session.passcodes = results.passcodes
        request.flash 'notice', "Populated"
      response.redirect '/events'

module.exports = EventsController
