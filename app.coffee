express       = require 'express'
mongooseAuth  = require 'mongoose-auth'

app = module.exports = express.createServer()

#core math requirement for money calculations
Math.roundToFixed = (num, dec) -> Math.round(num*Math.pow(10, dec))/Math.pow(10,dec)

#load configuration
require('./settings').boot app

app.dynamicHelpers
  base: ->
    if '/' == app.route then '' else app.route
  appName: (req, res) -> 'tilt investor app'

#Routes...
require('./app/routes')(app)

#add route for login check via REST
app.get '/login.json', (req, res) ->
  res.contentType('application/json')
  if (req.user)
    res.send(JSON.stringify(req.user))
  else
    res.send(JSON.stringify({error: "not authorized."}))


#setup express helpers for login and register
mongooseAuth.helpExpress(app)

port = process.env.PORT || 3000
app.listen port
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
