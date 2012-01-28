require('./db_connect');

var Team = new Schema({
  name        : {type: String, required: true}, 
  users       : [{ type: Schema.ObjectId, ref: 'User'}], 
  created_at  : {type : Date, default : Date.now},
  updated_at  : {type : Date, default : Date.now}
});

var exports = module.exports = mongoose.model('Team', Team);