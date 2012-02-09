var db_connect = require('./db_connect')
  , mongooseAuth = require('mongoose-auth'); 

var UserSchema = new Schema({
  username      : {type: String, required: true },
  email         : {type: String, required: true}, 
  team          : {type: Schema.ObjectId, ref: 'Team'},
  funds         : {type: [Number], default: [0,0,0]},
  created_at    : {type : Date, default : Date.now},
  updated_at    : {type : Date, default : Date.now}
}), User;

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
          , loginLocals: {title: 'Login'}
          , getRegisterPath: '/register'
          , postRegisterPath: '/register'
          , registerView: 'register.jade'
          , registerLocals: {title: 'Register'}
          , loginSuccessRedirect: '/'
          , registerSuccessRedirect: '/'
           , respondToLoginSucceed: function (res, user) {
              if (user) {
                if (res.req.query.json != null) {
                  res.redirect('/login.json');
                } else {
                  res.redirect('/');
                }
                res.end();
              }
            }
            , respondToLoginFail: function (req, res, errors, login) {
              if (errors && errors.length > 0) {
                if (req.query.json != null) {
                  res.redirect('/login.json');
                  res.end();  
                } else {
                  res.render('login',
                    { errors: errors
                      , title: 'Login'
                      , email: login
                    }); 
                }
              }
          }
         
        }
    }
});

var Team = require('./team');

UserSchema.pre('save', function (next) {
  var user = this; 
    
  //check and perform switched teams  
  leaveTeam(user.oldTeam, function(err) {
    joinTeam(user.team, function(err) {
      next();
    });
  });
  
  function leaveTeam(teamId, callback){
    if (teamId && user.team != teamId) {
      Team.findOne({_id: teamId}, function(err, team) {
        if (err) return callback(err);
        team.users.splice(team.users.indexOf(user._id), 1);
        team.save(function(err) {
          if (err) return next(err);
          return callback();
        });
      });
    } else callback();
  };

  function joinTeam(teamId, callback) {
    if (teamId) {
      Team.findOne({ _id: teamId }, function(err, team) {
        if (err) return next(err);
        if (team.users.indexOf(user.id) < 0) {
          team.users.push(user._id);
          team.save(function(err) {
            if (err) return next(err);
            return callback();
          });
        } else callback();  
      });
    } else callback();
  };
});

mongoose.model('User', UserSchema);

var exports = module.exports = User = mongoose.model('User');