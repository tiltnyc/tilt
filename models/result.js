require('./db_connect');

var Result = new Schema({
  team          : {type: Schema.ObjectId, ref: 'Team', required: true},
  round         : {type: Schema.ObjectId, ref: 'Round', required: true},
  before_price  : {type: Number, required: true},
  after_price   : {type: Number, required: true},
  movement      : {type: Number, required: true},
  movement_percentage : {type: Number, default: 0},
  percentage_score : {type: Number, required: true},
  created_at    : {type : Date, default : Date.now},
  updated_at    : {type : Date, default : Date.now}
});

var exports = module.exports = mongoose.model('Result', Result);