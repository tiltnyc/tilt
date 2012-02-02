//deps
var fs = require('fs'),
    stylus = require('stylus'),
    express = require('express'),
    gzippo = require('gzippo'),
    mongooseAuth = require('mongoose-auth');

//export the boot function
exports.boot = function(app) {
  bootApplication(app);
  bootErrorConfig(app);  
}


function bootApplication(app) {
  app.configure(function() {
    app.set('views', __dirname + '/views');
    app.set('view engine', 'jade');
    app.set('view options', { layout: 'layouts/default' });

    app.use(express.bodyParser());
    app.use(express.methodOverride());

    app.use(express.cookieParser());
    app.use(express.session({ secret: 'flkjgjoieolk' }));
    
    app.use(express.logger(':method :url :status'));
    app.use(express.favicon());

    app.use(app.router);
  });

  app.dynamicHelpers({

    request: function(req){
      return req;
    },

    hasMessages: function(req){
      if (!req.session) return false;
      return Object.keys(req.session.flash || {}).length;
    },

    // flash messages
    messages: require('express-messages')
    
  });

  function compile(str, path) {
    return stylus(str)
      .set('filename', path)
      .set('warn', true)
      .set('compress', true)
  // .define('url', stylus.url({ paths: [__dirname + '/public/images'], limit:1000000 }));
  };

  // add the stylus middleware, which re-compiles when
  // a stylesheet has changed, compiling FROM src,
  // TO dest. dest is optional, defaulting to src

  app.use(stylus.middleware({
      debug: true
    , src: __dirname + '/stylus'
    , dest: __dirname + '/public'
    , compile: compile
  }));

  app.set('showStackError', false);

  // configure environments

  var oneYear = 31557600000;

  app.configure('development', function(){
    app.set('showStackError', true);
    app.use(express.static(__dirname + '/public', { maxAge: oneYear }));
  });

  app.configure('test', function(){
    app.set('showStackError', true);
    app.use(express.static(__dirname + '/public', { maxAge: oneYear }));
  });

  // gzip only in staging and production envs

  app.configure('staging', function(){
    app.use(gzippo.staticGzip(__dirname + '/public', { maxAge: oneYear }));
    //app.enable('view cache');
  });

  app.configure('production', function(){
    app.use(gzippo.staticGzip(__dirname + '/public', { maxAge: oneYear }));
    // view cache is enabled by default in production mode
  });

}

// Error configuration

function bootErrorConfig(app) {

  // When no more middleware require execution, aka
  // our router is finished and did not respond, we
  // can assume that it is "not found". Instead of
  // letting Connect deal with this, we define our
  // custom middleware here to simply pass a NotFound
  // exception

  app.use(function(req, res, next){
    next(new NotFound(req.url));
  });

  // Provide our app with the notion of NotFound exceptions

  function NotFound(path){
    this.name = 'NotFound';
    if (path) {
      Error.call(this, 'Cannot find ' + path);
      this.path = path;
    } else {
      Error.call(this, 'Not Found');
    }
    Error.captureStackTrace(this, arguments.callee);
  }

  /**
   * Inherit from `Error.prototype`.
   */

  NotFound.prototype.__proto__ = Error.prototype;

  // We can call app.error() several times as shown below.
  // Here we check for an instanceof NotFound and show the
  // 404 page, or we pass on to the next error handler.

  // These handlers could potentially be defined within
  // configure() blocks to provide introspection when
  // in the development environment.

  app.error(function(err, req, res, next){
    if (err instanceof NotFound){
      console.log(err.stack);
      res.render('404', {
        layout: 'layouts/default',
        status: 404,
        error: err,
        showStack: app.settings.showStackError,
        title: 'Oops! The page you requested desn\'t exist'
      });
    }
    else {
      console.log(err.stack);
      res.render('500', {
        layout: 'layouts/default',
        status: 500,
        error: err,
        showStack: app.settings.showStackError,
        title: 'Oops! Something went wrong!'
      });
    }
  });


  /**
   * Apply basic auth to all post related routes
   */

  // If you need basic auth, uncomment the below
  /*
  app.all('(/*)?', basicAuth(function(user, pass){
    return 'user' == user && 'pass' == pass;
  }));
  */

  // Routes

 
}