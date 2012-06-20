(function() {
  var ObjectId, Schema, Team, User, UserSchema, exports, mongoose, mongooseAuth, _ref;

  _ref = require("./db_connect"), mongoose = _ref.mongoose, Schema = _ref.Schema, ObjectId = _ref.ObjectId;

  mongooseAuth = require("mongoose-auth");

  UserSchema = new Schema({
    username: {
      type: String,
      required: true
    },
    email: {
      type: String,
      required: true
    },
    team: {
      type: ObjectId,
      ref: "Team"
    },
    funds: {
      type: [Number],
      "default": []
    },
    is_admin: {
      type: Boolean,
      "default": false
    },
    created_at: {
      type: Date,
      "default": Date.now
    },
    updated_at: {
      type: Date,
      "default": Date.now
    }
  });

  UserSchema.methods.getFundsForRoundNbr = function(roundNbr) {
    return this.funds[roundNbr - 1];
  };

  UserSchema.methods.addFundsForRoundNbr = function(roundNbr, funds) {
    var i, _funds;
    i = roundNbr - 1;
    _funds = this.funds.concat();
    if (!_funds[i]) _funds[i] = 0;
    _funds[i] += funds;
    return this.funds = _funds;
  };

  UserSchema.methods.addToTeam = function(team) {
    this.oldTeam = this.team;
    return this.team = team;
  };

  User = void 0;

  UserSchema.plugin(mongooseAuth, {
    everymodule: {
      everyauth: {
        User: function() {
          return User;
        }
      }
    },
    password: {
      loginWith: "email",
      extraParams: {
        username: String
      },
      everyauth: {
        getLoginPath: "/login",
        postLoginPath: "/login",
        loginView: "login.jade",
        loginLocals: {
          title: "Login"
        },
        getRegisterPath: "/register",
        postRegisterPath: "/register",
        registerView: "register.jade",
        registerLocals: {
          title: "Register"
        },
        loginSuccessRedirect: "/user/dash",
        registerSuccessRedirect: "/",
        respondToLoginSucceed: function(res, user) {
          if (user) {
            if (res.req.query.json != null) {
              res.redirect("/login.json");
            } else {
              res.redirect("/user/dash");
            }
            return res.end();
          }
        },
        respondToLoginFail: function(req, res, errors, login) {
          if (errors && errors.length > 0) {
            if (req.query.json != null) {
              res.redirect("/login.json");
              return res.end();
            } else {
              return res.render("login", {
                errors: errors,
                title: "Login",
                email: login
              });
            }
          }
        }
      }
    }
  });

  Team = require("./team");

  UserSchema.pre("save", function(next) {
    var joinTeam, leaveTeam;
    leaveTeam = function(user, callback) {
      if (!user.oldTeam) return callback();
      return Team.findOne({
        _id: user.oldTeam
      }, function(err, team) {
        if (err) return callback(err);
        team.users.splice(team.users.indexOf(user._id), 1);
        return team.save(function(err) {
          return callback(err != null ? err : null);
        });
      });
    };
    joinTeam = function(user, callback) {
      if (!user.team) return callback();
      return Team.findById(user.team, function(err, team) {
        if (err) return callback(err);
        if (!team || team.users.indexOf(user.id) >= 0) callback();
        team.users.push(user._id);
        return team.save(function(err) {
          return callback(err != null ? err : null);
        });
      });
    };
    return leaveTeam(this, function(err) {
      if (err) {
        return next(err);
      } else {
        return joinTeam(this, function(err) {
          return next(err != null ? err : null);
        });
      }
    });
  });

  mongoose.model("User", UserSchema);

  exports = module.exports = User = mongoose.model("User");

}).call(this);
