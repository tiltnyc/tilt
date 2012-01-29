require('./db_connect');

var Investment = new Schema({
  amount      : {type: Number, required: true},
  user        : {type: Schema.ObjectId, ref: 'User'},
  stage       : {type : String},
  team        : {type: Schema.ObjectId, ref: 'Team'}, 
  created_at  : {type : Date, default : Date.now},
  updated_at  : {type : Date, default : Date.now}
});

var exports = module.exports = mongoose.model('Investment', Investment);