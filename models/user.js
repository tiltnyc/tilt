require('./db_connect');

var User = new Schema({
  username    : {type: String, required: true },
  email       : {type: String, required: true},
  team        : {type: Schema.ObjectId, ref: 'Team'},
  created_at  : {type : Date, default : Date.now},
  updated_at  : {type : Date, default : Date.now}
});


var Team = require('./team');

User.pre('save', function (next) {
  if (this.team) {
    var user = this; 
    Team
    .findOne({ _id: this.team }, function(err, team) {
      if (err) return next(err);
      team.users.push(user._id);
      team.save(function(err) {
        if (err) return next(err);
      });  
    });
  }
   
  next();
});

var exports = module.exports = mongoose.model('User', User);