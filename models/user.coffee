{mongoose, Schema, ObjectId} = require("./db_connect")
mongooseAuth = require("mongoose-auth")
UserSchema = new Schema(
  username:
    type: String
    required: true

  email:
    type: String
    required: true

  team:
    type: ObjectId
    ref: "Team"

  funds:
    type: [ Number ]
    default: []

  is_admin:
    type: Boolean
    default: false

  created_at:
    type: Date
    default: Date.now

  updated_at:
    type: Date
    default: Date.now
)

UserSchema.methods.getFundsForRoundNbr = (roundNbr) ->
  @funds[roundNbr - 1]

UserSchema.methods.addFundsForRoundNbr = (roundNbr, funds) ->
  i = roundNbr - 1
  _funds = @funds.concat()
  _funds[i] = 0 unless _funds[i]
  _funds[i] += funds
  @funds = _funds

UserSchema.methods.addToTeam = (team) ->
  @oldTeam = @team
  @team = team

User = undefined
UserSchema.plugin mongooseAuth,
  everymodule:
    everyauth:
      User: ->
        User

  password:
    loginWith: "email"
    extraParams:
      username: String

    everyauth:
      getLoginPath: "/login"
      postLoginPath: "/login"
      loginView: "login.jade"
      loginLocals:
        title: "Login"

      getRegisterPath: "/register"
      postRegisterPath: "/register"
      registerView: "register.jade"
      registerLocals:
        title: "Register"

      loginSuccessRedirect: "/user/dash"
      registerSuccessRedirect: "/"
      respondToLoginSucceed: (res, user) ->
        if user
          if res.req.query.json?
            res.redirect "/login.json"
          else
            res.redirect "/user/dash"
          res.end()

      respondToLoginFail: (req, res, errors, login) ->
        if errors and errors.length > 0
          if req.query.json?
            res.redirect "/login.json"
            res.end()
          else
            res.render "login",
              errors: errors
              title: "Login"
              email: login

Team = require("./team")
UserSchema.pre "save", (next) ->
  
  leaveTeam = (user, callback) -> 
    return callback() unless user.oldTeam
    Team.findById user.oldTeam, (err, team) ->
      return callback(err)  if err
      team.users.splice team.users.indexOf(user._id), 1
      team.save (err) -> 
        user.oldTeam = null
        callback(err ? null)
  
  joinTeam = (user, callback) ->
    return callback() unless user.team
    Team.findById user.team, (err, team) ->
      return callback(err)  if err
      callback() if !team or team.users.indexOf(user.id) >= 0
      team.users.push user._id
      team.save (err) -> callback(err ? null)
  user = @

  leaveTeam user, (err) -> 
    if err then next err  
    else joinTeam user, (err) -> next(err ? null)

mongoose.model "User", UserSchema
exports = module.exports = User = mongoose.model("User")