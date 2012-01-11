var express = require('express')
  , routes = require('./routes')

var app = module.exports = express.createServer();

// load configuration
require('./settings').boot(app);

app.dynamicHelpers({
  base: function(){
    // return the app's mount-point
    // so that urls can adjust. For example
    // if you run this example /post/add works
    // however if you run the mounting example
    // it adjusts to /blog/post/add
    return '/' == app.route ? '' : app.route;
  },
  appName: function(req, res){ return 'tilt investor app'  }
});

// Routes - todo.. include all routes here as made
app.get('/', routes.index);

require('./routes/users')(app);

var port = process.env.PORT || 3000;
app.listen(port);
console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);