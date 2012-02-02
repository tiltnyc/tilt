var db_connect = require('./db_connect')
  , mongooseAuth = require('mongoose-auth'); 

var UserSchema = new Schema({
  username      : {type: String, required: true },
  email         : {type: String, required: true},
  team          : {type: Schema.ObjectId, ref: 'Team'},
  funds         : {type: Number, default: 0},
  created_at    : {type : Date, default : Date.now},
  updated_at    : {type : Date, default : Date.now}
});

UserSchema.plugin(mongooseAuth, {
    everymodule: {
      everyauth: {
          User: function () {
            return User;
          }
      }
    }
  , password: {
        loginWith: 'email'
      , extraParams: {
          username: String
        }
      , everyauth: {
            getLoginPath: '/login'
          , postLoginPath: '/login'
          , loginView: 'login.jade'
          , getRegisterPath: '/register'
          , postRegisterPath: '/register'
          , registerView: 'register.jade'
          , loginSuccessRedirect: '/'
          , registerSuccessRedirect: '/'
        }
    }
});

var Team = require('./team');

UserSchema.pre('save', function (next) {
  var user = this; 
    
  //switched teams  
  if (this.oldTeam && this.team != this.oldTeam) {
    Team
    .findOne({ _id: this.oldTeam }, function(err, team) {
      if (err) return next(err);
      team.users.splice(team.users.indexOf(user._id), 1);
      team.save(function(err) {
        if (err) return next(err);
      });  
    });
  //added to team
  } 

  if (this.team) {
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

var exports = module.exports = mongoose.model('User', UserSchema);