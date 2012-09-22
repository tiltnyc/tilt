{mongoose, Schema, ObjectId} = require("./db_connect")

mongooseAuth = require("mongoose-auth")
Competitor = require("./competitor")
Investor = require("./investor")

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

  investing_in: [
    type: ObjectId
    ref: "Investor"
  ]

  created_at:
    type: Date
    default: Date.now

  updated_at:
    type: Date
    default: Date.now
)

UserSchema.methods.joinAsCompetitor = (event, done) ->
  Competitor.findOne(event: event.id, user: @id).exec (err, comp) =>
    return done "already joined" if comp
    new Competitor
      user: @id
      event: event.id
    .save (err, competitor) =>
      return done err if err
      done null, competitor
      @competing_in ?= []
      @competing_in.push competitor
      @save()

UserSchema.methods.joinAsInvestor = (event, done) ->
  Investor.findOne(event: event.id, user: @id).exec (err, inv) =>
    return done "already joined" if inv
    new Investor
      user: @id
      event: event.id
    .save (err, investor) =>
      return done err if err
      done null, investor
      @investing_in ?= []
      @investing_in.push investor
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
