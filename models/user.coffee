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
  leaveTeam = (teamId, callback) ->
    if teamId and user.team isnt teamId
      Team.findOne
        _id: teamId
      , (err, team) ->
        return callback(err)  if err
        team.users.splice team.users.indexOf(user._id), 1
        team.save (err) ->
          return callback(err)  if err
          callback()
    else
      callback()
  joinTeam = (teamId, callback) ->
    if teamId
      Team.findOne
        _id: teamId
      , (err, team) ->
        return callback(err)  if err
        return callback()  unless team
        if team.users.indexOf(user.id) < 0
          team.users.push user._id
          team.save (err) ->
            return callback(err)  if err
            callback()
        else
          callback()
    else
      callback()
  user = this
  leaveTeam user.oldTeam, (err) ->
    joinTeam user.team, (err) ->
      next()

mongoose.model "User", UserSchema
exports = module.exports = User = mongoose.model("User")