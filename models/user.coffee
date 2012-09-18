{mongoose, Schema, ObjectId} = require("./db_connect")

mongooseAuth = require("mongoose-auth")
Competitor = require("./competitor")

UserSchema = new Schema(
  username:
    type: String
    required: true

  email:
    type: String
    required: true

  is_admin:
    type: Boolean
    default: false

  competing_in: [
    type: ObjectId
    ref: "Competitor"
  ]

  created_at:
    type: Date
    default: Date.now

  updated_at:
    type: Date
    default: Date.now
)

UserSchema.methods.joinEvent = (event, done) ->
  new Competitor
    user: @id
    event: event.id
  .save (err, competitor) =>
    return done err if err
    done null, competitor
    @competing_in ?= []
    @competing_in.push competitor
    @save()

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

      loginSuccessRedirect: "/user/profile"
      registerSuccessRedirect: "/"
      respondToLoginSucceed: (res, user) ->
        if user
          if res.req.query.json?
            res.redirect "/login.json"
          else
            res.redirect "/user/profile"
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


mongoose.model "User", UserSchema
exports = module.exports = User = mongoose.model("User")
