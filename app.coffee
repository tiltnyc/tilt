express       = require 'express'
mongooseAuth  = require 'mongoose-auth'

app = module.exports = express.createServer()
app.listen process.env.PORT || 3003

#core math requirement for money calculations
Math.roundToFixed = (num, dec) -> Math.round(num*Math.pow(10, dec))/Math.pow(10,dec)

#load configuration
require('./settings').boot app

#Routes...
require('./app/routes')(app)

#setup express helpers for login and register
mongooseAuth.helpExpress(app)

console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env