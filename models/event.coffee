Sluggize   = require '../lib/sluggable'
addTimestamps = require '../lib/timestamps'

{ mongoose, Schema, ObjectId } = require './db_connect'

Event = new Schema
  name:
    type: String
    required: true

  date:
    type: Date

  venue:
    type: String

  theme:
    type: String

  picture:
    type: String

Event = addTimestamps(Event)
Event = Sluggize.sluggable(Event, 'name')

module.exports = Sluggize.findable(mongoose.model('Event', Event))
