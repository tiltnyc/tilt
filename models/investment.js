require('./db_connect');

var Investment = new Schema({
  percentage  : {type: Number, required: true},
  user        : {type: Schema.ObjectId, ref: 'User'},
  round       : {type: Number, required: true},
  team        : {type: Schema.ObjectId, ref: 'Team'}, 
  created_at  : {type : Date, default : Date.now},
  updated_at  : {type : Date, default : Date.now}
});

var exports = module.exports = mongoose.model('Investment', Investment);