{mongoose, Schema, ObjectId} = require("./db_connect")

mongooseAuth = require("mongoose-auth")

UserSchema = new Schema(
  user:
    type: ObjectId
    ref: "User"
    required: true

  event:
    type: ObjectId 
    ref:  "Event"
    required: true
  
  team:
    type: ObjectId
    ref: "Team"

  funds:
    type: [ Number ]
    default: []

  created_at:
    type: Date
    default: Date.now

  updated_at:
    type: Date
    default: Date.now
)