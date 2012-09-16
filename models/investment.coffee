{mongoose, Schema, ObjectId} = require("./db_connect")

Investment = new Schema(
  percentage:
    type: Number
    required: true

  competitor:
    type: ObjectId
    ref: "Competitor"

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
)
exports = module.exports = mongoose.model("Investment", Investment)