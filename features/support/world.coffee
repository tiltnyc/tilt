process.env.NODE_ENV ||= 'test'

zombie                       = require("zombie")
HTML5                        = require("html5")
should                       = require("should")
server                       = require("../../app")
databaseCleaner              = require("database-cleaner")
{mongoose, Schema, ObjectId} = require("../../models/db_connect")
dbCleaner                    = new DatabaseCleaner("mongodb")

exports.World = (callback) ->
  @browser = new zombie.Browser(
    runScripts: true
    debug: true
    htmlParser: HTML5
  )

  @page = (path) ->
    "http://localhost:" + server.address().port + path

  @visit = (path, callback) ->
    @browser.visit @page(path), (err, browser, status) ->
      callback err, browser, status

  @clean = (callback) ->
    dbCleaner.clean mongoose.connection.db, callback

  callback this
