fs = require('fs')
exports = mongoose = require('mongoose')
environment = process.env.NODE_ENV or 'development'
if environment is 'production'
  mongo_uri = process.env.MONGOLAB_URI
else
  mongo_uri = JSON.parse(fs.readFileSync(process.cwd() + '/config.json', encoding = 'utf8'))[environment].mongo_uri
mongoose.connect mongo_uri

module.exports =
  mongoose: mongoose
  Schema: mongoose.Schema
  ObjectId: mongoose.Schema.ObjectId
