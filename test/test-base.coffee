should = require "should"
databaseCleaner = require("database-cleaner")
{mongoose, Schema, ObjectId} = require("../models/db_connect")

cleaner = new DatabaseCleaner("mongodb")

create = (Model, props, done) ->
  instance = new Model props
  instance.save (err) ->
    throw err if err
    done()
  instance

Math.roundToFixed = (num, dec) -> Math.round(num*Math.pow(10, dec))/Math.pow(10,dec)

module.exports = 
  should: should
  clean: (callback) -> cleaner.clean mongoose.connection.db, callback
  create: create