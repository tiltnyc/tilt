{mongoose, Schema, ObjectId} = require("./db_connect")
Team = new Schema(
  name:
    type: String
    required: true

  users: [
    type: ObjectId
    ref: "User"
   ]
   
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
)
exports = module.exports = mongoose.model("Team", Team)