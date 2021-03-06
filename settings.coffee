stylus       = require "stylus"
express      = require "express"
mongooseAuth = require "mongoose-auth"
url          = require "url"
RedisStore = require('connect-redis')(express)

bootApplication = (app) ->
  compile = (str, path) ->
    stylus(str).set("filename", path).set("warn", true).set "compress", true

  app.configure "production", () ->
    redisUrl = url.parse(process.env.REDISTOGO_URL)
    redisAuth = redisUrl.auth.split(':')  
    app.set('redisHost', redisUrl.hostname)
    app.set('redisPort', redisUrl.port)
    app.set('redisDb', redisAuth[0])
    app.set('redisPass', redisAuth[1])

  oneday = 3600000 * 24
  app.configure ->
    app.set "views", __dirname + "/views"
    app.set "view engine", "jade"
    app.set "view options",
      layout: "layouts/default"

    app.use express.bodyParser()
    app.use express.methodOverride()
    app.use express.cookieParser()
    app.use express.session
      secret: process.env.TILT_SESSION_SECRET
      cookie:
        maxAge: oneday * 5
      store: new RedisStore
        host: app.set('redisHost')
        port: app.set('redisPort')
        db: app.set('redisDb')
        pass: app.set('redisPass')

    # To log requests, uncomment the following line
    #app.use express.logger(":method :url :status")

    app.use express.favicon()
    app.use mongooseAuth.middleware()
    app.use app.router

    #TODO figure out how to have unzipped assets in test
    #app.use require("connect-assets")({ minifyBuilds: false, build: false })
    app.set 'showStackError', false
    
    app.use express.static(__dirname + '/public', { maxAge: 31557600000 })



  app.dynamicHelpers
    request: (req) ->
      req

    hasMessages: (req) ->
      return false unless req.session
      Object.keys(req.session.flash or {}).length

    messages: require("express-messages")


bootErrorConfig = (app) ->
  NotFound = (path) ->
    @name = "NotFound"
    if path
      Error.call this, "Cannot find " + path
      @path = path
    else
      Error.call this, "Not Found"
    Error.captureStackTrace this, arguments.callee

  app.use (req, res, next) ->
    next new NotFound(req.url)

  NotFound::__proto__ = Error::

  app.error (err, req, res, next) ->
    console.log err.stack

    if err instanceof NotFound
      res.render "404",
        layout: "layouts/default"
        status: 404
        error: err
        showStack: app.settings.showStackError
        title: "Oops! The page you requested desn't exist"
    else
      res.render "500",
        layout: "layouts/default"
        status: 500
        error: err
        showStack: app.settings.showStackError
        title: "Oops! Something went wrong!"


# Todo Refactor, so the user model is not required here
require("./models/user")

exports.boot = (app) ->
  bootApplication app
  bootErrorConfig app
