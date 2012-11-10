addTimestamps = require '../lib/timestamps'

{ mongoose, Schema, ObjectId } = require './db_connect'

Vote = new Schema
  competitor:
    type: ObjectId
    ref: 'Competitor'
    required: true

  team:
    type: ObjectId
    ref: 'Team'
    required: true

  round:
    type: ObjectId
    ref: 'Round'
    required: true

  event:
    type: ObjectId
    ref:  'Event'
    required: true

Vote = addTimestamps(Vote)

exports = module.exports = mongoose.model('Vote', Vote)
