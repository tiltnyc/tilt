timestamps = require '../lib/timestamps'

{ mongoose, Schema, ObjectId } = require './db_connect'

Investment = new Schema
  percentage:
    type: Number
    required: true

  investor:
    type: ObjectId
    ref: "Investor"

  round:
    type: ObjectId
    ref: "Round"
    required: true

  event:
    type: ObjectId 
    ref:  "Event"
    required: true

  team:
    type: ObjectId
    ref: "Team"

  created_at:
    type: Date
    default: Date.now

  updated_at:
    type: Date
    default: Date.now

Investment = timestamps(Investment)

exports = module.exports = mongoose.model('Investment', Investment)
