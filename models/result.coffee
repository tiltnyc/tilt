{mongoose, Schema, ObjectId} = require("./db_connect")

Result = new Schema(
  team:
    type: ObjectId
    ref: "Team"
    required: true

  event:
    type: ObjectId 
    ref:  "Event"
    #required: true JM: should be required in future
    
  round:
    type: ObjectId
    ref: "Round"
    required: true

  before_price:
    type: Number
    required: true

  after_price:
    type: Number
    required: true

  movement:
    type: Number
    required: true

  movement_percentage:
    type: Number
    default: 0

  percentage_score:
    type: Number
    required: true

  created_at:
    type: Date
    default: Date.now

  updated_at:
    type: Date
    default: Date.now
)
exports = module.exports = mongoose.model("Result", Result)