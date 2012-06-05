{mongoose, Schema, ObjectId} = require("./db_connect")

Round = new Schema(
  number:
    type: Number
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

  factor:
    type: Number
    default: 1

  average:
    type: Number
    default: 0

  created_at:
    type: Date
    default: Date.now

  updated_at:
    type: Date
    default: Date.now
)
Round.virtual("processed").get ->
  @standard_deviation?

exports = module.exports = mongoose.model("Round", Round)