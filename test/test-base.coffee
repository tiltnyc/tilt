should = require "should"
databaseCleaner = require("database-cleaner")
{mongoose, Schema, ObjectId} = require("../models/db_connect")

cleaner = new DatabaseCleaner("mongodb")
factory = require "./factory"


Math.roundToFixed = (num, dec) -> Math.round(num*Math.pow(10, dec))/Math.pow(10,dec)
Math.randomIntTo = (to) -> Math.floor(Math.random() * to) 


module.exports = 
  should: should
  clean: (callback) -> cleaner.clean mongoose.connection.db, callback
  factory: factory
  create: factory.create