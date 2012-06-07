should = require "should"
databaseCleaner = require("database-cleaner")
{mongoose, Schema, ObjectId} = require("../models/db_connect")

cleaner = new DatabaseCleaner("mongodb")

module.exports = 
  should: should
  clean: (callback) -> cleaner.clean mongoose.connection.db, callback