{mongoose, Schema, ObjectId} = require("./db_connect")
Vote = new Schema
  competitor:
    type: ObjectId
    ref: "Competitor"
    required: true

  team:
    type: ObjectId
    ref: "Team"
    required: true

  round:
    type: ObjectId
    ref: "Round"
    required: true

exports = module.exports = mongoose.model("Vote", Vote)