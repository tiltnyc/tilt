{mongoose, Schema, ObjectId} = require("./db_connect")
Team = new Schema
  name:
    type: String
    required: true

  event: 
    type: ObjectId
    ref: "Event"
    required: true
       
  competitors: [
    type: ObjectId
    ref: "Competitor"
  ]

  out_since:
    type: Number
    default: 0

  tagline:
    type: String

  desc:
    type: String
  
  twitter:
    type: String
    
  picture: 
    type: String
    default: "https://s3.amazonaws.com/tiltnyc/teams/generic-team.jpg"
    
  last_price:
    type: Number
    default: 1.00

  movement:
    type: Number
    default: 0

  movement_percentage:
    type: Number
    default: 0

  created_at:
    type: Date
    default: Date.now

  updated_at:
    type: Date
    default: Date.now

Team.virtual("is_out").get -> @out_since > 0

exports = module.exports = mongoose.model("Team", Team)