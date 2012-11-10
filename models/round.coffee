addTimestamps = require '../lib/timestamps'

{ mongoose, Schema, ObjectId } = require './db_connect'

Round = new Schema
  number:
    type: Number
    required: true

  event:
    type: ObjectId
    ref:  'Event'
    required: true

  is_current:
    type: Boolean
    default: false

  is_open:
    type: Boolean
    default: false

  allocated:
    type: Number
    default: 0

  standard_deviation:
    type: Number

  total_funds:
    type: Number
    default: 0

  investor_count:
    type: Number
    default: 0

  vote_count:
    type: Number
    default: 0

  average_team_votes:
    type: Number
    default: 0

  factor:
    type: Number
    default: 1

  average:
    type: Number
    default: 0

Round = addTimestamps(Round)

Round.virtual('processed').get ->
  @standard_deviation?

Round.virtual('is_first').get ->
  Number(@number) is 1

exports = module.exports = mongoose.model('Round', Round)
