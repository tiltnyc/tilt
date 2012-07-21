bootApplication = (app) ->
  compile = (str, path) ->
    stylus(str).set("filename", path).set("warn", true).set "compress", true

  app.configure ->
    app.set "views", __dirname + "/views"
    app.set "view engine", "jade"
    app.set "view options",
      layout: "layouts/default"

    app.use express.bodyParser()
    app.use express.methodOverride()
    app.use express.cookieParser()
    app.use express.session(secret: "flkjgjoieolk")
    app.use express.logger(":method :url :status")
    app.use express.favicon()
    app.use mongooseAuth.middleware()
    app.use app.router

  app.dynamicHelpers
    request: (req) ->
      req

    hasMessages: (req) ->
      return false  unless req.session
      Object.keys(req.session.flash or {}).length

    messages: require("express-messages")

  app.use require("connect-assets")()

  app.use stylus.middleware(
    debug: true
    src: __dirname + "/stylus"
    dest: __dirname + "/public"
    compile: compile
  )

  app.set "showStackError", false

  oneYear = 31557600000

  app.configure "development", ->
    app.set "showStackError", true
    app.use express.static(__dirname + "/public",
      maxAge: oneYear
    )

  app.configure "test", ->
    app.set "showStackError", true
    app.use express.static(__dirname + "/public",
      maxAge: oneYear
    )

  app.configure "staging", ->
    app.use gzippo.staticGzip(__dirname + "/public",
      maxAge: oneYear
    )

  app.configure "production", ->
    app.use gzippo.staticGzip(__dirname + "/public",
      maxAge: oneYear
    )

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

fs           = require("fs")
stylus       = require("stylus")
express      = require("express")
gzippo       = require("gzippo")
mongooseAuth = require("mongoose-auth")

# Todo Refactor, so the user model is not required here
require("./models/user")

exports.boot = (app) ->
  bootApplication app
  bootErrorConfig app
