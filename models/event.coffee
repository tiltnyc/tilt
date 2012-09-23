{mongoose, Schema, ObjectId} = require("./db_connect")

Event = new Schema
  name: 
    type: String
    required: true

  date:
    type: Date

  teams: [
    type: ObjectId
    ref: "Team"
  ]

  rounds: [
    type: ObjectId
    ref: "Round"
  ]

  picture: 
    type: String

  created_at:
    type: Date
    default: Date.now

  updated_at:
    type: Date
    default: Date.now

exports = module.exports = mongoose.model("Event", Event)