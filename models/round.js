require('./db_connect');

var Round = new Schema({
  number              : {type: Number, required: true},
  is_current          : {type: Boolean, default: false},
  is_open             : {type: Boolean, default: false},
  allocated           : {type: Number, default: 0},
  standard_deviation  : {type: Number}, 
  total_funds         : {type: Number, default: 0}, 
  investor_count      : {type: Number, default: 0},
  created_at          : {type : Date, default : Date.now},
  updated_at          : {type : Date, default : Date.now}
});

Round.virtual('processed').get(function () {
  return this.standard_deviation != null;
});

var exports = module.exports = mongoose.model('Round', Round);