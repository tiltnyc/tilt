{mongoose, Schema, ObjectId} = require("./db_connect")

Investment = new Schema(
  percentage:
    type: Number
    required: true

  user:
    type: ObjectId
    ref: "User"

  round:
    type: ObjectId
    ref: "Round"
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