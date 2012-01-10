require('./db_connect');

var User = new Schema({
  username    : {type: String, required: true },
  email       : {type: String, required: true },
  created_at  : {type : Date, default : Date.now},
  updated_at  : {type : Date, default : Date.now}
});

var exports = module.exports = mongoose.model('User', User);